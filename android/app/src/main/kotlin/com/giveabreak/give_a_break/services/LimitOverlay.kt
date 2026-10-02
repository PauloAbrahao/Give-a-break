package com.giveabreak.give_a_break.services

import android.accessibilityservice.AccessibilityService
import android.app.ActivityManager
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.giveabreak.give_a_break.R

class LimitOverlay(
    private val context: AccessibilityService,
    private val onClosed: () -> Unit
) {

    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val handler = Handler(Looper.getMainLooper())
    private var overlayView: View? = null
    private var restrictedPackageName: String? = null

    companion object {
        private const val DEFAULT_BUTTON_COLOR = "#6366F1"
        private const val DEFAULT_ICON = "clock"
        private const val SECONDS_PER_HOUR = 3600
        private const val SECONDS_PER_MINUTE = 60

        private val iconMap = mapOf(
            "clock" to R.drawable.ic_clock,
            "block" to R.drawable.ic_block,
            "warning" to R.drawable.ic_warning,
            "pause" to R.drawable.ic_pause,
            "house" to R.drawable.ic_house,
            "work" to R.drawable.ic_work,
            "bedtime" to R.drawable.ic_bedtime,
            "food" to R.drawable.ic_food,
            "movie" to R.drawable.ic_movie,
            "car" to R.drawable.ic_car,
            "gym" to R.drawable.ic_gym,
            "battery" to R.drawable.ic_battery,
            "game" to R.drawable.ic_game,
            "sun" to R.drawable.ic_sun
        )

        private const val DEFAULT_ICON_RESOURCE = R.drawable.ic_clock
    }

    fun show(
        packageName: String,
        usedSeconds: Int,
        limitSeconds: Int,
        openCount: Int,
        overlayColor: String?,
        overlayIcon: String?
    ) {
        if (overlayView != null) hide()

        restrictedPackageName = packageName
        val view = createOverlayView(
            getAppName(packageName),
            formatSeconds(usedSeconds),
            formatSeconds(limitSeconds),
            openCount,
            overlayColor ?: DEFAULT_BUTTON_COLOR,
            overlayIcon ?: DEFAULT_ICON
        )

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }

        windowManager.addView(view, params)
        overlayView = view
    }

    fun hide() {
        try {
            overlayView?.let { windowManager.removeView(it) }
        } catch (_: Exception) { }
        overlayView = null
    }

    private fun createOverlayView(
        appName: String,
        usedTime: String,
        limitTime: String,
        openCount: Int,
        overlayColor: String,
        overlayIcon: String
    ): View {
        val buttonColor = try {
            Color.parseColor(overlayColor)
        } catch (e: Exception) {
            Color.parseColor(DEFAULT_BUTTON_COLOR)
        }

        // Main container
        val mainLayout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#F0000000"))
            setPadding(dp(32), dp(64), dp(32), dp(64))
        }

        // Icon
        val iconDrawable = iconMap[overlayIcon] ?: DEFAULT_ICON_RESOURCE
        val iconView = ImageView(context).apply {
            setImageResource(iconDrawable)
            setColorFilter(buttonColor, android.graphics.PorterDuff.Mode.SRC_IN)
            layoutParams = LinearLayout.LayoutParams(dp(80), dp(80))
        }
        mainLayout.addView(iconView)

        addSpacer(mainLayout, 32)

        // Title
        val titleText = TextView(context).apply {
            text = "Time's Up!"
            textSize = 32f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setTypeface(null, android.graphics.Typeface.BOLD)
        }
        mainLayout.addView(titleText)

        addSpacer(mainLayout, 16)

        // Message
        val messageText = TextView(context).apply {
            text = "You've reached your limit for $appName"
            textSize = 16f
            setTextColor(Color.parseColor("#CCFFFFFF"))
            gravity = Gravity.CENTER
        }
        mainLayout.addView(messageText)

        addSpacer(mainLayout, 32)

        // Info card
        val infoCard = LinearLayout(context).apply {
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
        infoCard.addView(View(context).apply {
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 1)
            setBackgroundColor(Color.parseColor("#40FFFFFF"))
        })

        addSpacer(infoCard, 16)

        // Limit row
        infoCard.addView(createInfoRow("Daily limit", limitTime, "#FFFFFF"))

        addSpacer(infoCard, 16)

        // Divider
        infoCard.addView(View(context).apply {
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 1)
            setBackgroundColor(Color.parseColor("#40FFFFFF"))
        })

        addSpacer(infoCard, 16)

        // Opens row
        infoCard.addView(createInfoRow("Opens today", "$openCount", "#FFFFFF"))

        mainLayout.addView(infoCard)

        addSpacer(mainLayout, 48)

        // Take a Break button
        val breakButton = Button(context).apply {
            text = "Close"
            textSize = 16f
            setTextColor(Color.WHITE)
            background = GradientDrawable().apply {
                setColor(buttonColor)
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
        return LinearLayout(context).apply {
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
        layout.addView(View(context).apply {
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(heightDp))
        })
    }

    private fun dp(value: Int): Int = (value * context.resources.displayMetrics.density).toInt()

    private fun getAppName(packageName: String): String {
        return try {
            val pm = context.packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            packageName.split(".").last()
        }
    }

    private fun formatSeconds(totalSeconds: Int): String {
        val hours = totalSeconds / SECONDS_PER_HOUR
        val minutes = (totalSeconds % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE
        val seconds = totalSeconds % SECONDS_PER_MINUTE

        return when {
            hours > 0 -> if (minutes > 0) "${hours}h ${minutes}m" else "${hours}h"
            minutes > 0 -> if (seconds > 0) "${minutes}m ${seconds}s" else "${minutes}m"
            else -> "${seconds}s"
        }
    }

    private fun takeABreak() {
        val packageToKill = restrictedPackageName

        context.performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
        onClosed()

        // Remove overlay AFTER going to home so user doesn't see the restricted app
        handler.postDelayed({ hide() }, 150)

        // Kill background processes
        packageToKill?.let { packageName ->
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager

            handler.postDelayed({
                try {
                    activityManager.killBackgroundProcesses(packageName)
                } catch (_: Exception) {}
            }, 100)

            handler.postDelayed({
                try {
                    activityManager.killBackgroundProcesses(packageName)
                } catch (_: Exception) {}
            }, 300)

            handler.postDelayed({
                try {
                    activityManager.killBackgroundProcesses(packageName)
                } catch (_: Exception) {}
            }, 500)
        }
    }
}
