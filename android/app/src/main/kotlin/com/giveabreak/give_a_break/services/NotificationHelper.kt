package com.giveabreak.give_a_break.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationCompat
import com.giveabreak.give_a_break.MainActivity

class NotificationHelper(private val context: Context) {

    companion object {
        const val FOREGROUND_CHANNEL_ID = "app_monitor_channel"
        const val FOREGROUND_NOTIFICATION_ID = 1001

        private const val WARNING_CHANNEL_ID = "app_limit_warning"
    }

    private val notificationManager: NotificationManager
        get() = context.getSystemService(NotificationManager::class.java)

    fun createForegroundNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                FOREGROUND_CHANNEL_ID,
                "Background Service",
                NotificationManager.IMPORTANCE_MIN
            ).apply {
                description = "Required for app to run in background"
                setShowBadge(false)
                setSound(null, null)
                enableLights(false)
                enableVibration(false)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun createForegroundNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(context, FOREGROUND_CHANNEL_ID)
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

    fun showOverlay(
        packageName: String,
        usedSeconds: Int,
        limitSeconds: Int,
        openCount: Int,
        overlayColor: String? = null,
        overlayIcon: String? = null
    ) {
        val appName = getAppName(packageName)
        val usedTime = formatSeconds(usedSeconds)
        val limitTime = formatSeconds(limitSeconds)

        if (Settings.canDrawOverlays(context)) {
            OverlayService.show(
                context,
                appName,
                usedTime,
                limitTime,
                packageName,
                openCount,
                overlayColor,
                overlayIcon
            )
        } else {
            showHeadsUpNotification(appName, usedSeconds, limitSeconds)
        }
    }

    private fun showHeadsUpNotification(appName: String, usedSeconds: Int, limitSeconds: Int) {
        createWarningChannel()

        val pendingIntent = createMainActivityIntent()

        val notification = NotificationCompat.Builder(context, WARNING_CHANNEL_ID)
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

    private fun createWarningChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                WARNING_CHANNEL_ID,
                "App Limit Warnings",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications when app usage exceeds limits"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                setShowBadge(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createMainActivityIntent(): PendingIntent {
        return PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

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
        val hours = totalSeconds / 3600
        val minutes = (totalSeconds % 3600) / 60
        val seconds = totalSeconds % 60

        return when {
            hours > 0 -> if (minutes > 0) "${hours}h ${minutes}m" else "${hours}h"
            minutes > 0 -> if (seconds > 0) "${minutes}m ${seconds}s" else "${minutes}m"
            else -> "${seconds}s"
        }
    }
}
