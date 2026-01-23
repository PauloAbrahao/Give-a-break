package com.giveabreak.give_a_break.channels

import android.app.Activity
import android.content.Intent
import android.os.Build
import com.giveabreak.give_a_break.services.AppAccessibilityService
import com.giveabreak.give_a_break.services.AppMonitorService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object MonitorServiceChannel : MethodChannel.MethodCallHandler {
    private const val CHANNEL_NAME = "com.giveabreak/monitor_service"
    private lateinit var activity: Activity
    private lateinit var channel: MethodChannel

    fun register(activity: Activity, messenger: BinaryMessenger) {
        this.activity = activity
        channel = MethodChannel(messenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    fun getChannel(): MethodChannel = channel

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startService" -> {
                startMonitorService()
                result.success(true)
            }
            "stopService" -> {
                stopMonitorService()
                result.success(true)
            }
            "isServiceRunning" -> {
                // Service is effectively running if either the foreground service
                // or the accessibility service is active
                val isRunning = AppMonitorService.isRunning || AppAccessibilityService.isRunning
                result.success(isRunning)
            }
            "checkAccessibilityPermission" -> {
                val isEnabled = AppAccessibilityService.isAccessibilityServiceEnabled(activity)
                result.success(isEnabled)
            }
            "requestAccessibilityPermission" -> {
                AppAccessibilityService.openAccessibilitySettings(activity)
                result.success(true)
            }
            "isAccessibilityServiceRunning" -> {
                result.success(AppAccessibilityService.isRunning)
            }
            else -> result.notImplemented()
        }
    }

    private fun startMonitorService() {
        val intent = Intent(activity, AppMonitorService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.startForegroundService(intent)
        } else {
            activity.startService(intent)
        }
    }

    private fun stopMonitorService() {
        val intent = Intent(activity, AppMonitorService::class.java)
        activity.stopService(intent)
    }
}
