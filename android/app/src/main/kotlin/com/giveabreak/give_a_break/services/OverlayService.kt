package com.giveabreak.give_a_break.services

import android.app.ActivityManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class OverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var restrictedPackageName: String? = null

    companion object {
        private const val EXTRA_APP_NAME = "app_name"
        private const val EXTRA_USED_TIME = "used_time"
        private const val EXTRA_LIMIT_TIME = "limit_time"
        private const val EXTRA_PACKAGE_NAME = "package_name"

        fun show(context: Context, appName: String, usedTime: String, limitTime: String, packageName: String) {
            if (!Settings.canDrawOverlays(context)) return

            val intent = Intent(context, OverlayService::class.java).apply {
                putExtra(EXTRA_APP_NAME, appName)
                putExtra(EXTRA_USED_TIME, usedTime)
                putExtra(EXTRA_LIMIT_TIME, limitTime)
                putExtra(EXTRA_PACKAGE_NAME, packageName)
            }
            context.startService(intent)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val appName = intent?.getStringExtra(EXTRA_APP_NAME) ?: "App"
        val usedTime = intent?.getStringExtra(EXTRA_USED_TIME) ?: "--"
        val limitTime = intent?.getStringExtra(EXTRA_LIMIT_TIME) ?: "--"
        restrictedPackageName = intent?.getStringExtra(EXTRA_PACKAGE_NAME)

        showOverlay(appName, usedTime, limitTime)
        return START_NOT_STICKY
    }

    private fun showOverlay(appName: String, usedTime: String, limitTime: String) {
        if (overlayView != null) removeOverlay()

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        overlayView = createOverlayView(appName, usedTime, limitTime)

        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }

        windowManager?.addView(overlayView, params)
    }

    private fun createOverlayView(appName: String, usedTime: String, limitTime: String): View {
        // Main container
        val mainLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#F0000000"))
            setPadding(dp(32), dp(64), dp(32), dp(64))
        }

        // Icon
        val iconText = TextView(this).apply {
            text = "⏰"
            textSize = 64f
            gravity = Gravity.CENTER
        }
        mainLayout.addView(iconText)

        addSpacer(mainLayout, 32)

        // Title
        val titleText = TextView(this).apply {
            text = "Time's Up!"
            textSize = 32f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setTypeface(null, android.graphics.Typeface.BOLD)
        }
        mainLayout.addView(titleText)

        addSpacer(mainLayout, 16)

        // Message
        val messageText = TextView(this).apply {
            text = "You've reached your limit for $appName"
            textSize = 16f
            setTextColor(Color.parseColor("#CCFFFFFF"))
            gravity = Gravity.CENTER
        }
        mainLayout.addView(messageText)

        addSpacer(mainLayout, 32)

        // Info card
        val infoCard = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1E293B"))
                cornerRadius = dp(16).toFloat()
            }
            setPadding(dp(24), dp(20), dp(24), dp(20))
        }

        // Used time row
        infoCard.addView(createInfoRow("Used today", usedTime, "#EF4444"))
        addSpacer(infoCard, 16)

        // Divider
        infoCard.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 1)
            setBackgroundColor(Color.parseColor("#40FFFFFF"))
        })

        addSpacer(infoCard, 16)

        // Limit row
        infoCard.addView(createInfoRow("Daily limit", limitTime, "#FFFFFF"))

        mainLayout.addView(infoCard)

        addSpacer(mainLayout, 48)

        // Take a Break button
        val breakButton = Button(this).apply {
            text = "Take a Break"
            textSize = 16f
            setTextColor(Color.WHITE)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#6366F1"))
                cornerRadius = dp(12).toFloat()
            }
            setPadding(dp(32), dp(16), dp(32), dp(16))
            isAllCaps = false
            setOnClickListener { takeABreak() }
        }
        mainLayout.addView(breakButton)

        return mainLayout
    }

    private fun createInfoRow(label: String, value: String, valueColor: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL

            addView(TextView(context).apply {
                text = label
                textSize = 14f
                setTextColor(Color.parseColor("#B0FFFFFF"))
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
            })

            addView(TextView(context).apply {
                text = value
                textSize = 18f
                setTextColor(Color.parseColor(valueColor))
                setTypeface(null, android.graphics.Typeface.BOLD)
            })
        }
    }

    private fun addSpacer(layout: LinearLayout, heightDp: Int) {
        layout.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(heightDp))
        })
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    private fun takeABreak() {
        removeOverlay()

        // Go to home screen first (puts restricted app in background)
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)

        // Kill the restricted app's background processes
        restrictedPackageName?.let { packageName ->
            try {
                val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                activityManager.killBackgroundProcesses(packageName)
            } catch (e: Exception) {
                // Silently fail if unable to kill process
            }
        }

        stopSelf()
    }

    private fun removeOverlay() {
        try {
            overlayView?.let { windowManager?.removeView(it) }
            overlayView = null
        } catch (e: Exception) { }
    }

    override fun onDestroy() {
        super.onDestroy()
        removeOverlay()
    }
}
