package com.giveabreak.give_a_break.services

import android.app.Service
import android.content.Intent
import android.os.IBinder

/**
 * Foreground service that keeps the app alive in background.
 *
 * This service only maintains a foreground notification to prevent the system
 * from killing the app. The actual app detection is handled by [AppAccessibilityService]
 * which provides instant detection when apps are opened.
 */
class AppMonitorService : Service() {

    private lateinit var notificationHelper: NotificationHelper

    companion object {
        @Volatile
        var isRunning = false
            private set
    }

    override fun onCreate() {
        super.onCreate()
        isRunning = true

        notificationHelper = NotificationHelper(this)
        notificationHelper.createForegroundNotificationChannel()
        startForeground(
            NotificationHelper.FOREGROUND_NOTIFICATION_ID,
            notificationHelper.createForegroundNotification()
        )
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
    }
}
