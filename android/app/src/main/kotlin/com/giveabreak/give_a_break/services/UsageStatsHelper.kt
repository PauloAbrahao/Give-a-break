package com.giveabreak.give_a_break.services

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import com.giveabreak.give_a_break.services.models.AppUsageToday
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

    fun getUsageToday(packageNames: Set<String>): Map<String, AppUsageToday> {
        if (packageNames.isEmpty()) return emptyMap()
        val manager = usageStatsManager ?: return emptyMap()

        val (startTime, endTime) = getTodayTimeRange()
        val usageEvents = manager.queryEvents(startTime, endTime) ?: return emptyMap()

        val usedMillis = mutableMapOf<String, Long>()
        val openCounts = mutableMapOf<String, Int>()
        val lastResumeTimes = mutableMapOf<String, Long>()
        var lastForegroundPkg: String? = null
        val event = UsageEvents.Event()

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            val packageName = event.packageName

            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED -> {
                    if (packageName in packageNames) {
                        lastResumeTimes[packageName] = event.timeStamp
                        if (packageName != lastForegroundPkg) {
                            openCounts[packageName] = (openCounts[packageName] ?: 0) + 1
                        }
                    }
                    lastForegroundPkg = packageName
                }
                UsageEvents.Event.ACTIVITY_PAUSED -> {
                    val resumeTime = lastResumeTimes.remove(packageName) ?: continue
                    usedMillis[packageName] = (usedMillis[packageName] ?: 0L) + event.timeStamp - resumeTime
                }
            }
        }

        lastResumeTimes.forEach { (packageName, resumeTime) ->
            usedMillis[packageName] = (usedMillis[packageName] ?: 0L) + endTime - resumeTime
        }

        return packageNames.associateWith {
            AppUsageToday(usedMillis[it] ?: 0L, openCounts[it] ?: 0)
        }
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
