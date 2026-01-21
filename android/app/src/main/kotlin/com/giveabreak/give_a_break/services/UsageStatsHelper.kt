package com.giveabreak.give_a_break.services

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import java.util.Calendar

class UsageStatsHelper(private val context: Context) {

    private val usageStatsManager: UsageStatsManager?
        get() = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager

    fun getCurrentForegroundApp(): String? {
        val manager = usageStatsManager ?: return null

        val endTime = System.currentTimeMillis()
        val startTime = endTime - 60000

        val usageEvents = manager.queryEvents(startTime, endTime) ?: return null

        var lastResumedPackage: String? = null
        var lastResumedTime = 0L

        val event = UsageEvents.Event()
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                if (event.timeStamp > lastResumedTime) {
                    lastResumedTime = event.timeStamp
                    lastResumedPackage = event.packageName
                }
            }
        }

        // Fallback: use queryUsageStats if no events
        if (lastResumedPackage == null) {
            val stats = manager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            )
            if (!stats.isNullOrEmpty()) {
                val recentStat = stats.maxByOrNull { it.lastTimeUsed }
                if (recentStat != null && recentStat.lastTimeUsed > endTime - 5000) {
                    lastResumedPackage = recentStat.packageName
                }
            }
        }

        return lastResumedPackage
    }

    fun getAppUsageToday(packageName: String): Int {
        val manager = usageStatsManager ?: return 0

        val (startTime, endTime) = getTodayTimeRange()
        val usageEvents = manager.queryEvents(startTime, endTime) ?: return 0

        var totalTime = 0L
        var lastResumeTime: Long? = null
        val event = UsageEvents.Event()

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)

            if (event.packageName == packageName) {
                when (event.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED -> {
                        lastResumeTime = event.timeStamp
                    }
                    UsageEvents.Event.ACTIVITY_PAUSED -> {
                        lastResumeTime?.let { resumeTime ->
                            totalTime += event.timeStamp - resumeTime
                        }
                        lastResumeTime = null
                    }
                }
            }
        }

        // If app is currently in foreground, add time since last resume
        lastResumeTime?.let { resumeTime ->
            totalTime += endTime - resumeTime
        }

        return (totalTime / 1000).toInt()
    }

    fun getAppOpenCountToday(packageName: String): Int {
        val manager = usageStatsManager ?: return 0

        val (startTime, endTime) = getTodayTimeRange()
        val usageEvents = manager.queryEvents(startTime, endTime) ?: return 0

        var openCount = 0
        var lastForegroundPkg: String? = null
        val event = UsageEvents.Event()

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                if (event.packageName == packageName && event.packageName != lastForegroundPkg) {
                    openCount++
                }
                lastForegroundPkg = event.packageName
            }
        }

        return openCount
    }

    fun getLastResumeTime(packageName: String): Long {
        val manager = usageStatsManager ?: return 0

        val endTime = System.currentTimeMillis()
        val startTime = endTime - 300000 // Last 5 minutes

        val usageEvents = manager.queryEvents(startTime, endTime) ?: return 0

        var lastResumeTime = 0L
        val event = UsageEvents.Event()

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.packageName == packageName && event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                if (event.timeStamp > lastResumeTime) {
                    lastResumeTime = event.timeStamp
                }
            }
        }

        return lastResumeTime
    }

    private fun getTodayTimeRange(): Pair<Long, Long> {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return Pair(calendar.timeInMillis, System.currentTimeMillis())
    }
}
