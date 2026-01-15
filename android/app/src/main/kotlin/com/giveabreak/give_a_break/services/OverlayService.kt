package com.giveabreak.give_a_break.services

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class OverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    companion object {
        private const val EXTRA_APP_NAME = "app_name"
        private const val EXTRA_USED_TIME = "used_time"
        private const val EXTRA_LIMIT_TIME = "limit_time"

        fun show(context: Context, appName: String, usedTime: String, limitTime: String) {
            if (!Settings.canDrawOverlays(context)) return

            val intent = Intent(context, OverlayService::class.java).apply {
                putExtra(EXTRA_APP_NAME, appName)
                putExtra(EXTRA_USED_TIME, usedTime)
                putExtra(EXTRA_LIMIT_TIME, limitTime)
            }
            context.startService(intent)
        }

        fun hide(context: Context) {
            context.stopService(Intent(context, OverlayService::class.java))
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val appName = intent?.getStringExtra(EXTRA_APP_NAME) ?: "App"
        val usedTime = intent?.getStringExtra(EXTRA_USED_TIME) ?: "--"
        val limitTime = intent?.getStringExtra(EXTRA_LIMIT_TIME) ?: "--"

        showOverlay(appName, usedTime, limitTime)
        return START_NOT_STICKY
    }

    private fun showOverlay(appName: String, usedTime: String, limitTime: String) {
        if (overlayView != null) {
            removeOverlay()
        }

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        // Create overlay view programmatically
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
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }

        windowManager?.addView(overlayView, params)
    }

    private fun createOverlayView(appName: String, usedTime: String, limitTime: String): View {
        val context = this

        // Main container with dark background
        val mainLayout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#E6000000"))
            setPadding(48, 48, 48, 48)
        }

        // Warning icon container
        val iconContainer = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            val size = dpToPx(100)
            layoutParams = LinearLayout.LayoutParams(size, size)
            setBackgroundColor(Color.parseColor("#33F59E0B"))
        }

        val iconText = TextView(context).apply {
            text = "⏰"
            textSize = 48f
            gravity = Gravity.CENTER
        }
        iconContainer.addView(iconText)
        mainLayout.addView(iconContainer)

        // Spacer
        mainLayout.addView(View(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(32)
            )
        })

        // Title
        val titleText = TextView(context).apply {
            text = "Time's Up!"
            textSize = 28f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
        }
        mainLayout.addView(titleText)

        // Spacer
        mainLayout.addView(View(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(16)
            )
        })

        // Message
        val messageText = TextView(context).apply {
            text = "You've reached your limit for $appName"
            textSize = 16f
            setTextColor(Color.parseColor("#CCFFFFFF"))
            gravity = Gravity.CENTER
        }
        mainLayout.addView(messageText)

        // Spacer
        mainLayout.addView(View(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(32)
            )
        })

        // Info card
        val infoCard = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#1E293B"))
            setPadding(dpToPx(20), dpToPx(20), dpToPx(20), dpToPx(20))
        }

        // Used time row
        val usedRow = createInfoRow("Used today:", usedTime, Color.parseColor("#EF4444"))
        infoCard.addView(usedRow)

        // Divider
        infoCard.addView(View(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                1
            ).apply { setMargins(0, dpToPx(12), 0, dpToPx(12)) }
            setBackgroundColor(Color.parseColor("#40FFFFFF"))
        })

        // Limit row
        val limitRow = createInfoRow("Daily limit:", limitTime, Color.WHITE)
        infoCard.addView(limitRow)

        mainLayout.addView(infoCard)

        // Spacer
        mainLayout.addView(View(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(48)
            )
        })

        // Take a Break button
        val breakButton = Button(context).apply {
            text = "Take a Break"
            textSize = 16f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#6366F1"))
            setPadding(dpToPx(24), dpToPx(16), dpToPx(24), dpToPx(16))
            setOnClickListener {
                removeOverlay()
                stopSelf()
            }
        }
        mainLayout.addView(breakButton)

        // Spacer
        mainLayout.addView(View(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(16)
            )
        })

        // Continue anyway button
        val continueButton = TextView(context).apply {
            text = "Continue anyway"
            textSize = 14f
            setTextColor(Color.parseColor("#80FFFFFF"))
            gravity = Gravity.CENTER
            setPadding(dpToPx(16), dpToPx(8), dpToPx(16), dpToPx(8))
            setOnClickListener {
                removeOverlay()
                stopSelf()
            }
        }
        mainLayout.addView(continueButton)

        return mainLayout
    }

    private fun createInfoRow(label: String, value: String, valueColor: Int): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL

            val labelView = TextView(context).apply {
                text = label
                textSize = 14f
                setTextColor(Color.parseColor("#B0FFFFFF"))
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
            }
            addView(labelView)

            val valueView = TextView(context).apply {
                text = value
                textSize = 16f
                setTextColor(valueColor)
            }
            addView(valueView)
        }
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }

    private fun removeOverlay() {
        try {
            overlayView?.let {
                windowManager?.removeView(it)
                overlayView = null
            }
        } catch (e: Exception) {
            // View might already be removed
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        removeOverlay()
    }
}
