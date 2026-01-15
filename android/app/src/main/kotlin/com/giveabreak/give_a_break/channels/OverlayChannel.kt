package com.giveabreak.give_a_break.channels

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object OverlayChannel : MethodChannel.MethodCallHandler {
    private const val CHANNEL_NAME = "com.giveabreak/overlay"
    private lateinit var activity: Activity
    private lateinit var channel: MethodChannel

    fun register(activity: Activity, messenger: BinaryMessenger) {
        this.activity = activity
        channel = MethodChannel(messenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkPermission" -> {
                result.success(hasOverlayPermission())
            }
            "requestPermission" -> {
                openOverlaySettings()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(activity)
        } else {
            true
        }
    }

    private fun openOverlaySettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:${activity.packageName}")
            )
            activity.startActivity(intent)
        }
    }
}
