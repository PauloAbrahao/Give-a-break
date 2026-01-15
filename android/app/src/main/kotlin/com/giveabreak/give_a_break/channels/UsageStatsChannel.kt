package com.giveabreak.give_a_break.channels

import android.app.Activity
import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.app.usage.UsageEvents
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object UsageStatsChannel : MethodChannel.MethodCallHandler {
    private const val CHANNEL_NAME = "com.giveabreak/usage_stats"
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
                result.success(hasUsageStatsPermission())
            }
            "requestPermission" -> {
                openUsageAccessSettings()
                result.success(true)
            }
            "getUsageStats" -> {
                val startTime = call.argument<Long>("startTime") ?: 0L
                val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                val stats = getUsageStats(startTime, endTime)
                result.success(stats)
            }
            "getUsageEvents" -> {
                val startTime = call.argument<Long>("startTime") ?: 0L
                val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                val events = getUsageEvents(startTime, endTime)
                result.success(events)
            }
            "getForegroundApp" -> {
                val foregroundApp = getCurrentForegroundApp()
                result.success(foregroundApp)
            }
            else -> result.notImplemented()
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = activity.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                activity.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                activity.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        activity.startActivity(intent)
    }

    private fun getUsageStats(startTime: Long, endTime: Long): List<Map<String, Any>> {
        if (!hasUsageStatsPermission()) return emptyList()

        val usageStatsManager =
            activity.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)

        val appUsageMap = mutableMapOf<String, Long>()
        val lastResumeMap = mutableMapOf<String, Long>()

        val event = UsageEvents.Event()

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)

            val pkg = event.packageName
            val time = event.timeStamp

            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED -> {
                    lastResumeMap[pkg] = time
                }

                UsageEvents.Event.ACTIVITY_PAUSED -> {
                    val start = lastResumeMap[pkg]
                    if (start != null) {
                        val duration = time - start
                        appUsageMap[pkg] = (appUsageMap[pkg] ?: 0L) + duration
                        lastResumeMap.remove(pkg)
                    }
                }
            }
        }

        return appUsageMap.map { (pkg, duration) ->
            mapOf(
                "packageName" to pkg,
                "totalTimeInForeground" to duration,
                "lastTimeUsed" to endTime,
                "firstTimeStamp" to startTime
            )
        }
    }

    private fun getUsageEvents(startTime: Long, endTime: Long): List<Map<String, Any>> {
        if (!hasUsageStatsPermission()) {
            return emptyList()
        }

        val usageStatsManager = activity.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
        val events = mutableListOf<Map<String, Any>>()

        while (usageEvents.hasNextEvent()) {
            val event = UsageEvents.Event()
            usageEvents.getNextEvent(event)

            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                event.eventType == UsageEvents.Event.ACTIVITY_PAUSED
            ) {
                events.add(
                    mapOf(
                        "packageName" to event.packageName,
                        "timestamp" to event.timeStamp,
                        "eventType" to event.eventType
                    )
                )
            }
        }
        return events
    }

    private fun getCurrentForegroundApp(): String? {
        if (!hasUsageStatsPermission()) {
            return null
        }

        val usageStatsManager = activity.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 10000 // Last 10 seconds

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
        var lastResumedPackage: String? = null
        var lastResumedTime = 0L

        while (usageEvents.hasNextEvent()) {
            val event = UsageEvents.Event()
            usageEvents.getNextEvent(event)

            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                if (event.timeStamp > lastResumedTime) {
                    lastResumedTime = event.timeStamp
                    lastResumedPackage = event.packageName
                }
            }
        }
        return lastResumedPackage
    }
}
