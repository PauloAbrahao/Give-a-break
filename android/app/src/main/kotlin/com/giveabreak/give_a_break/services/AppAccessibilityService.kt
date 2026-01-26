package com.giveabreak.give_a_break.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import android.view.accessibility.AccessibilityEvent

/**
 * Accessibility Service that provides instant detection of app launches.
 *
 * Unlike UsageStatsManager polling which has inherent delays, this service
 * receives events immediately when a new window/activity comes to foreground,
 * allowing the overlay to be shown before the user sees the restricted app.
 */
class AppAccessibilityService : AccessibilityService() {

    private var lastPackageName: String? = null
    private var limitChecker: LimitChecker? = null
    private var launcherPackage: String? = null

    companion object {
        private const val TAG = "AppAccessibilityService"

        @Volatile
        var isRunning = false
            private set

        @Volatile
        private var instance: AppAccessibilityService? = null

        /**
         * Force close an app by pressing back multiple times.
         * This helps ensure the app is fully closed and not just in background.
         */
        fun forceCloseCurrentApp() {
            instance?.let { service ->
                // Press back multiple times to ensure app is closed
                service.performGlobalAction(GLOBAL_ACTION_BACK)
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    service.performGlobalAction(GLOBAL_ACTION_BACK)
                }, 100)
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    service.performGlobalAction(GLOBAL_ACTION_BACK)
                }, 200)
            }
        }

        /**
         * Check if the accessibility service is enabled in system settings.
         */
        fun isAccessibilityServiceEnabled(context: Context): Boolean {
            val expectedComponentName = ComponentName(context, AppAccessibilityService::class.java)
            val enabledServices = Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: return false

            val colonSplitter = TextUtils.SimpleStringSplitter(':')
            colonSplitter.setString(enabledServices)

            while (colonSplitter.hasNext()) {
                val componentNameString = colonSplitter.next()
                val enabledComponent = ComponentName.unflattenFromString(componentNameString)
                if (enabledComponent != null && enabledComponent == expectedComponentName) {
                    return true
                }
            }

            return false
        }

        /**
         * Open the accessibility settings screen.
         */
        fun openAccessibilitySettings(context: Context) {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        }
    }

    private fun getDefaultLauncherPackage(): String? {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isRunning = true
        instance = this

        limitChecker = LimitChecker(applicationContext)
        launcherPackage = getDefaultLauncherPackage()

        // Configure for instant detection - no timeout, minimal flags
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 0  // No delay
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        try {
            if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

            val checker = limitChecker ?: return // Not initialized yet

            val packageName = event.packageName?.toString() ?: return

            // Skip system UI and our own app
            if (packageName == "com.android.systemui" ||
                packageName == this.packageName ||
                packageName == "com.giveabreak.give_a_break") {
                return
            }

            if (packageName == launcherPackage) {
                lastPackageName = null
                checker.onAppChanged(packageName)
                return
            }

            if (packageName == lastPackageName) return

            checker.onAppChanged(packageName)

            lastPackageName = packageName

            checkAppLimits(packageName, checker)
        } catch (e: Exception) {
            Log.e(TAG, "Error processing accessibility event: ${e.message}", e)
        }
    }

    private fun checkAppLimits(packageName: String, checker: LimitChecker) {
        try {
            when (val result = checker.checkApp(packageName)) {
                is LimitChecker.CheckResult.LimitExceeded -> {
                    checker.handleLimitExceeded(
                        packageName,
                        result.usedSeconds,
                        result.limitSeconds,
                        result.openCount
                    )
                }
                LimitChecker.CheckResult.NoLimit,
                LimitChecker.CheckResult.RoutineInactive,
                LimitChecker.CheckResult.WithinLimit -> {
                    // No action needed
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking app limits for $packageName: ${e.message}", e)
        }
    }

    override fun onInterrupt() {
        // Required override - called when the service is interrupted
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        instance = null
        limitChecker = null
        Log.d(TAG, "Accessibility service destroyed")
    }
}
