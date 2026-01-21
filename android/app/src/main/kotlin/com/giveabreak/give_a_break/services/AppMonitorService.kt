package com.giveabreak.give_a_break.services

import android.app.Service
import android.content.Intent
import android.os.Handler
import android.os.IBinder
import android.os.Looper

/**
 * Foreground service that monitors app usage and enforces limits.
 *
 * This service runs in the background and periodically checks which app is in the foreground.
 * When a monitored app exceeds its limits (time or openings), it triggers overlays or notifications.
 *
 * The service delegates responsibilities to:
 * - [LimitChecker]: Coordinates limit checking logic
 * - [NotificationHelper]: Handles all notifications
 * - [UsageStatsHelper]: Tracks app usage statistics
 * - [LimitManager]: Manages limit and routine configurations
 */
class AppMonitorService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private var monitoringRunnable: Runnable? = null
    private var lastForegroundPackage: String? = null

    private lateinit var limitChecker: LimitChecker
    private lateinit var notificationHelper: NotificationHelper

    companion object {
        private const val MONITOR_INTERVAL = 100L // 100ms for fast detection

        @Volatile
        var isRunning = false
            private set
    }

    override fun onCreate() {
        super.onCreate()
        isRunning = true

        limitChecker = LimitChecker(this)
        notificationHelper = NotificationHelper(this)

        notificationHelper.createForegroundNotificationChannel()
        startForeground(
            NotificationHelper.FOREGROUND_NOTIFICATION_ID,
            notificationHelper.createForegroundNotification()
        )
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
        val foregroundPackage = limitChecker.getCurrentForegroundApp() ?: return

        // Skip if it's our own app
        if (foregroundPackage == packageName) return

        when (val result = limitChecker.checkApp(foregroundPackage)) {
            is LimitChecker.CheckResult.LimitExceeded -> {
                limitChecker.handleLimitExceeded(
                    foregroundPackage,
                    result.usedSeconds,
                    result.limitSeconds
                )
            }
            is LimitChecker.CheckResult.WarningThreshold -> {
                limitChecker.handleWarningThreshold(
                    foregroundPackage,
                    result.usedSeconds,
                    result.limitSeconds
                )
            }
            LimitChecker.CheckResult.NoLimit,
            LimitChecker.CheckResult.RoutineInactive,
            LimitChecker.CheckResult.WithinLimit -> {
                // No action needed
            }
        }

        lastForegroundPackage = foregroundPackage
    }
}
