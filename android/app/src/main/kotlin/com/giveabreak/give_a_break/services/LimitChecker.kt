package com.giveabreak.give_a_break.services

import android.content.Context

/**
 * Handles the logic of checking app limits and determining what action to take.
 * This class coordinates between UsageStatsHelper, LimitManager, and NotificationHelper.
 */
class LimitChecker(context: Context) {

    private val usageStatsHelper = UsageStatsHelper(context)
    private val limitManager = LimitManager(context)
    private val notificationHelper = NotificationHelper(context)

    private var lastOverlayShownForResumeTime: Long = 0

    data class LimitConfig(
        val dailyLimitSeconds: Int,
        val dailyLimitOpenings: Int
    )

    sealed class CheckResult {
        object NoLimit : CheckResult()
        object RoutineInactive : CheckResult()
        object WithinLimit : CheckResult()
        data class LimitExceeded(val usedSeconds: Int, val limitSeconds: Int) : CheckResult()
    }

    fun checkApp(packageName: String): CheckResult {
        // First, check if app belongs to a routine
        val routine = limitManager.getRoutineForApp(packageName)

        if (routine != null) {
            // If routine is not active now (wrong day/time), skip all limits
            if (!limitManager.isRoutineActiveNow(routine)) {
                return CheckResult.RoutineInactive
            }

            // Use limits from routine
            return checkLimits(
                packageName,
                LimitConfig(
                    dailyLimitSeconds = routine.dailyLimitSeconds,
                    dailyLimitOpenings = routine.dailyLimitOpenings
                )
            )
        }

        // App is not in any routine, use individual limits
        val limit = limitManager.getAppLimit(packageName)
        if (limit == null || !limit.isEnabled) {
            return CheckResult.NoLimit
        }

        return checkLimits(
            packageName,
            LimitConfig(
                dailyLimitSeconds = limit.dailyLimitSeconds,
                dailyLimitOpenings = limit.dailyLimitOpenings
            )
        )
    }

    private fun checkLimits(packageName: String, config: LimitConfig): CheckResult {
        val usageTodaySeconds = usageStatsHelper.getAppUsageToday(packageName)
        val openingsToday = usageStatsHelper.getAppOpenCountToday(packageName)

        val openingsLimitReached = config.dailyLimitOpenings > 0 &&
                                   openingsToday >= config.dailyLimitOpenings
        val timeLimitReached = config.dailyLimitSeconds > 0 &&
                               usageTodaySeconds >= config.dailyLimitSeconds

        if (timeLimitReached || openingsLimitReached) {
            return CheckResult.LimitExceeded(usageTodaySeconds, config.dailyLimitSeconds)
        }

        return CheckResult.WithinLimit
    }

    fun handleLimitExceeded(packageName: String, usedSeconds: Int, limitSeconds: Int) {
        val lastResumeTime = usageStatsHelper.getLastResumeTime(packageName)

        // Show overlay once per app resume
        if (lastResumeTime != lastOverlayShownForResumeTime) {
            lastOverlayShownForResumeTime = lastResumeTime
            val openCount = usageStatsHelper.getAppOpenCountToday(packageName)

            // Get overlay customization from routine
            val routine = limitManager.getRoutineForApp(packageName)
            val overlayColor = routine?.overlayColor
            val overlayIcon = routine?.overlayIcon

            notificationHelper.showOverlay(
                packageName,
                usedSeconds,
                limitSeconds,
                openCount,
                overlayColor,
                overlayIcon
            )
        }
    }

    fun getCurrentForegroundApp(): String? = usageStatsHelper.getCurrentForegroundApp()
}
