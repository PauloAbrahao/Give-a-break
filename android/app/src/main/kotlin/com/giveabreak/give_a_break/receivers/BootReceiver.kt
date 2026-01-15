package com.giveabreak.give_a_break.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import com.giveabreak.give_a_break.services.AppMonitorService

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Check if monitoring was enabled before reboot
            val prefs = context.getSharedPreferences("give_a_break_prefs", Context.MODE_PRIVATE)
            val monitoringEnabled = prefs.getBoolean("monitoring_enabled", false)

            if (monitoringEnabled) {
                val serviceIntent = Intent(context, AppMonitorService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
            }
        }
    }
}
