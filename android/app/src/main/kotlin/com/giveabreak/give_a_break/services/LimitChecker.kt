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
    private var lastWarningShownTime: Long = 0
    private var lastWarningShownPackage: String? = null

    companion object {
        private const val DEFAULT_WARNING_THRESHOLD = 0.8
        private const val WARNING_COOLDOWN_MS = 200
    }

    data class LimitConfig(
        val dailyLimitSeconds: Int,
        val dailyLimitOpenings: Int,
        val warningThreshold: Double
    )

    sealed class CheckResult {
        object NoLimit : CheckResult()
        object RoutineInactive : CheckResult()
        object WithinLimit : CheckResult()
        data class LimitExceeded(val usedSeconds: Int, val limitSeconds: Int) : CheckResult()
        data class WarningThreshold(val usedSeconds: Int, val limitSeconds: Int) : CheckResult()
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
                    dailyLimitOpenings = routine.dailyLimitOpenings,
                    warningThreshold = DEFAULT_WARNING_THRESHOLD
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
                dailyLimitOpenings = limit.dailyLimitOpenings,
                warningThreshold = limit.warningThreshold
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

        // Check warning threshold
        if (config.dailyLimitSeconds > 0) {
            val warningTimeSeconds = (config.dailyLimitSeconds * config.warningThreshold).toInt()
            if (usageTodaySeconds >= warningTimeSeconds) {
                return CheckResult.WarningThreshold(usageTodaySeconds, config.dailyLimitSeconds)
            }
        }

        return CheckResult.WithinLimit
    }

    fun handleLimitExceeded(packageName: String, usedSeconds: Int, limitSeconds: Int) {
        val lastResumeTime = usageStatsHelper.getLastResumeTime(packageName)

        // Show overlay once per app resume
        if (lastResumeTime != lastOverlayShownForResumeTime) {
            lastOverlayShownForResumeTime = lastResumeTime
            val openCount = usageStatsHelper.getAppOpenCountToday(packageName)
            notificationHelper.showOverlay(packageName, usedSeconds, limitSeconds, openCount)
        }
    }

    fun handleWarningThreshold(packageName: String, usedSeconds: Int, limitSeconds: Int) {
        val lastResumeTime = usageStatsHelper.getLastResumeTime(packageName)
        val appResumedAfterLastWarning = lastResumeTime > lastWarningShownTime + WARNING_COOLDOWN_MS
        val isDifferentApp = packageName != lastWarningShownPackage

        if (appResumedAfterLastWarning || isDifferentApp) {
            lastWarningShownTime = System.currentTimeMillis()
            lastWarningShownPackage = packageName
            notificationHelper.showWarningNotification(packageName, usedSeconds, limitSeconds)
        }
    }

    fun getCurrentForegroundApp(): String? = usageStatsHelper.getCurrentForegroundApp()
}
