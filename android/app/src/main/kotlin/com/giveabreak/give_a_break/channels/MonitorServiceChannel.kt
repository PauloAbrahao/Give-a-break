package com.giveabreak.give_a_break.channels

import android.app.Activity
import com.giveabreak.give_a_break.services.AppAccessibilityService
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
            "isServiceRunning" -> {
                val isRunning = AppAccessibilityService.isRunning
                result.success(isRunning)
            }
            "isMonitoringFullyFunctional" -> {
                val isEnabled = AppAccessibilityService.isAccessibilityServiceEnabled(activity)
                val isConnected = AppAccessibilityService.isRunning
                result.success(isEnabled && isConnected)
            }
            "needsAccessibilityReconnect" -> {
                val isEnabled = AppAccessibilityService.isAccessibilityServiceEnabled(activity)
                val isConnected = AppAccessibilityService.isRunning
                result.success(isEnabled && !isConnected)
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
}
