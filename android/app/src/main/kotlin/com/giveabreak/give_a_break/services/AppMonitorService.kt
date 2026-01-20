package com.giveabreak.give_a_break.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.net.Uri
import android.util.Log
import androidx.core.app.NotificationCompat
import com.giveabreak.give_a_break.MainActivity
import org.json.JSONArray
import java.util.Calendar

class AppMonitorService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var monitoringRunnable: Runnable? = null
    private var lastForegroundPackage: String? = null
    private var lastOverlayShownTime: Long = 0
    private var lastOverlayShownPackage: String? = null
    private var lastWarningShownTime: Long = 0
    private var lastWarningShownPackage: String? = null
    private val lastKnownUsage = mutableMapOf<String, Int>()

    companion object {
        private const val TAG = "AppMonitorService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "app_monitor_channel"
        private const val MONITOR_INTERVAL = 100L // 100ms for fast detection
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val LIMITS_KEY = "flutter.app_limits_json"

        @Volatile
        var isRunning = false
            private set
    }

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
        startMonitoring()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        stopMonitoring()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Background Service",
                NotificationManager.IMPORTANCE_MIN
            ).apply {
                description = "Required for app to run in background"
                setShowBadge(false)
                setSound(null, null)
                enableLights(false)
                enableVibration(false)
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Give a Break")
            .setContentText("Running")
            .setSmallIcon(android.R.drawable.ic_menu_recent_history)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setVisibility(NotificationCompat.VISIBILITY_SECRET)
            .build()
    }

    private fun startMonitoring() {
        monitoringRunnable = object : Runnable {
            override fun run() {
                checkForegroundApp()
                handler.postDelayed(this, MONITOR_INTERVAL)
            }
        }
        handler.post(monitoringRunnable!!)
    }

    private fun stopMonitoring() {
        monitoringRunnable?.let { handler.removeCallbacks(it) }
        monitoringRunnable = null
    }

    private fun checkForegroundApp() {
        val foregroundPackage = getCurrentForegroundApp() ?: return

        if (foregroundPackage != packageName) {
            val limit = getAppLimit(foregroundPackage)
            if (limit != null && limit.isEnabled) {
                val usageTodaySeconds = getAppUsageToday(foregroundPackage)
                val dailyLimitSeconds = limit.dailyLimitSeconds
                // Calculate warning time based on threshold (e.g., 80% of daily limit)
                val warningTimeSeconds = (dailyLimitSeconds * limit.warningThreshold).toInt()

                val now = System.currentTimeMillis()
                val lastResumeTime = getLastResumeTime(foregroundPackage)

                // Check if limit is exceeded (100%) - show blocking overlay
                if (usageTodaySeconds >= dailyLimitSeconds) {
                    val appResumedAfterLastOverlay = lastResumeTime > lastOverlayShownTime + 200
                    val isDifferentApp = foregroundPackage != lastOverlayShownPackage
                    val previousUsage = lastKnownUsage[foregroundPackage] ?: 0
                    val justCrossedLimit = previousUsage < dailyLimitSeconds && usageTodaySeconds >= dailyLimitSeconds

                    if (appResumedAfterLastOverlay || isDifferentApp || justCrossedLimit) {
                        lastOverlayShownTime = now
                        lastOverlayShownPackage = foregroundPackage
                        showOverlay(foregroundPackage, usageTodaySeconds, dailyLimitSeconds)
                    }
                }
                // Check if warning threshold reached but not yet at limit - show warning notification
                else if (usageTodaySeconds >= warningTimeSeconds) {
                    val appResumedAfterLastWarning = lastResumeTime > lastWarningShownTime + 200
                    val isDifferentApp = foregroundPackage != lastWarningShownPackage

                    if (appResumedAfterLastWarning || isDifferentApp) {
                        lastWarningShownTime = now
                        lastWarningShownPackage = foregroundPackage
                        showWarningNotification(foregroundPackage, usageTodaySeconds, dailyLimitSeconds)
                    }
                }

                lastKnownUsage[foregroundPackage] = usageTodaySeconds
            }
            lastForegroundPackage = foregroundPackage
        }
    }

    private fun getLastResumeTime(packageName: String): Long {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return 0

        val endTime = System.currentTimeMillis()
        val startTime = endTime - 300000 // Last 5 minutes

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime) ?: return 0

        var lastResumeTime = 0L
        val event = UsageEvents.Event()

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.packageName == packageName && event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                if (event.timeStamp > lastResumeTime) {
                    lastResumeTime = event.timeStamp
                }
            }
        }

        return lastResumeTime
    }

    private fun getAppLimit(packageName: String): AppLimit? {
        try {
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val limitsJson = prefs.getString(LIMITS_KEY, null) ?: return null
            val jsonArray = JSONArray(limitsJson)

            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                if (obj.getString("packageName") == packageName) {
                    return AppLimit(
                        packageName = obj.getString("packageName"),
                        dailyLimitSeconds = obj.getInt("dailyLimitSeconds"),
                        isEnabled = obj.getBoolean("isEnabled"),
                        warningThreshold = obj.optDouble("warningThreshold", 0.8)
                    )
                }
            }
        } catch (e: Exception) {
            // JSON parsing error
        }
        return null
    }

    private fun getAppUsageToday(packageName: String): Int {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return 0

        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)

        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        // Use queryEvents and calculate time from RESUMED/PAUSED events (same as Flutter)
        val usageEvents = usageStatsManager.queryEvents(startTime, endTime) ?: return 0

        var totalTime = 0L
        var lastResumeTime: Long? = null
        val event = UsageEvents.Event()

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)

            if (event.packageName == packageName) {
                when (event.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED -> {
                        lastResumeTime = event.timeStamp
                    }
                    UsageEvents.Event.ACTIVITY_PAUSED -> {
                        lastResumeTime?.let { resumeTime ->
                            totalTime += event.timeStamp - resumeTime
                        }
                        lastResumeTime = null
                    }
                }
            }
        }

        // If app is currently in foreground, add time since last resume
        lastResumeTime?.let { resumeTime ->
            totalTime += endTime - resumeTime
        }

        // Return seconds instead of minutes for precision
        return (totalTime / 1000).toInt()
    }

    private fun showOverlay(packageName: String, usedSeconds: Int, limitSeconds: Int) {
        // Get app name from package manager
        val appName = try {
            val pm = applicationContext.packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            packageName.split(".").last()
        }

        val usedTime = formatSeconds(usedSeconds)
        val limitTime = formatSeconds(limitSeconds)

        // Show native overlay if permission granted
        if (Settings.canDrawOverlays(this)) {
            OverlayService.show(this, appName, usedTime, limitTime, packageName)
        } else {
            // Fallback to notification
            showHeadsUpNotification(appName, usedSeconds, limitSeconds)
        }
    }

    private fun showHeadsUpNotification(appName: String, usedSeconds: Int, limitSeconds: Int) {
        val notificationManager = getSystemService(NotificationManager::class.java)

        // Create high priority notification channel
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val warningChannel = NotificationChannel(
                "app_limit_warning",
                "App Limit Warnings",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications when app usage exceeds limits"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                setShowBadge(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            notificationManager.createNotificationChannel(warningChannel)
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(this, "app_limit_warning")
            .setContentTitle("⏰ Time's up for $appName!")
            .setContentText("Used: ${formatSeconds(usedSeconds)} | Limit: ${formatSeconds(limitSeconds)}")
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setVibrate(longArrayOf(0, 500, 200, 500))
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setFullScreenIntent(pendingIntent, true)
            .build()

        notificationManager.notify(System.currentTimeMillis().toInt(), notification)
    }

    private fun showWarningNotification(packageName: String, usedSeconds: Int, limitSeconds: Int) {
        val notificationManager = getSystemService(NotificationManager::class.java)

        // Get app name
        val appName = try {
            val pm = applicationContext.packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            packageName.split(".").last()
        }

        val remainingSeconds = limitSeconds - usedSeconds
        val remainingTime = formatSeconds(remainingSeconds)

        // Create warning notification channel
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val warningChannel = NotificationChannel(
                "app_limit_approaching",
                "App Limit Approaching",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications when approaching app usage limits"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 300, 150, 300)
                setShowBadge(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            notificationManager.createNotificationChannel(warningChannel)
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(this, "app_limit_approaching")
            .setContentTitle("⚠️ $appName - Limit approaching")
            .setContentText("$remainingTime remaining before your daily limit")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setVibrate(longArrayOf(0, 300, 150, 300))
            .build()

        notificationManager.notify(packageName.hashCode(), notification)
    }

    private fun formatSeconds(totalSeconds: Int): String {
        val hours = totalSeconds / 3600
        val minutes = (totalSeconds % 3600) / 60
        val seconds = totalSeconds % 60

        return when {
            hours > 0 -> {
                if (minutes > 0) "${hours}h ${minutes}m" else "${hours}h"
            }
            minutes > 0 -> {
                if (seconds > 0) "${minutes}m ${seconds}s" else "${minutes}m"
            }
            else -> "${seconds}s"
        }
    }

    private fun getCurrentForegroundApp(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return null

        val endTime = System.currentTimeMillis()
        val startTime = endTime - 60000

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime) ?: return null

        var lastResumedPackage: String? = null
        var lastResumedTime = 0L

        val event = UsageEvents.Event()
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                if (event.timeStamp > lastResumedTime) {
                    lastResumedTime = event.timeStamp
                    lastResumedPackage = event.packageName
                }
            }
        }

        // Fallback: use queryUsageStats if no events
        if (lastResumedPackage == null) {
            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            )
            if (!stats.isNullOrEmpty()) {
                val recentStat = stats.maxByOrNull { it.lastTimeUsed }
                if (recentStat != null && recentStat.lastTimeUsed > endTime - 5000) {
                    lastResumedPackage = recentStat.packageName
                }
            }
        }

        return lastResumedPackage
    }

    data class AppLimit(
        val packageName: String,
        val dailyLimitSeconds: Int,
        val isEnabled: Boolean,
        val warningThreshold: Double = 0.8
    )
}
