package com.giveabreak.give_a_break.services

import android.content.Context
import android.util.Log
import java.util.Calendar

/**
 * Handles the logic of checking app limits and determining what action to take.
 * This class coordinates between UsageStatsHelper, LimitManager, and NotificationHelper.
 */
class LimitChecker(context: Context) {

    companion object {
        private const val TAG = "LimitChecker"
        private const val OVERLAY_DEBOUNCE_MS = 2000L
    }

    private val usageStatsHelper = UsageStatsHelper(context)
    private val limitManager = LimitManager(context)
    private val notificationHelper = NotificationHelper(context)

    private val lastOverlayShownTime = mutableMapOf<String, Long>()

    private val exceededAppsCache = mutableMapOf<String, CachedLimitResult>()
    private var cacheDate: Int = -1

    private data class CachedLimitResult(
        val usedSeconds: Int,
        val limitSeconds: Int,
        val openCount: Int
    )

    data class LimitConfig(
        val dailyLimitSeconds: Int,
        val dailyLimitOpenings: Int
    )

    sealed class CheckResult {
        object NoLimit : CheckResult()
        object RoutineInactive : CheckResult()
        object WithinLimit : CheckResult()
        data class LimitExceeded(
            val usedSeconds: Int,
            val limitSeconds: Int,
            val openCount: Int
        ) : CheckResult()
    }

    fun checkApp(packageName: String): CheckResult {
        val today = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)
        if (today != cacheDate) {
            exceededAppsCache.clear()
            cacheDate = today
        }

        // First, check if app belongs to a routine
        val routine = limitManager.getRoutineForApp(packageName)

        if (routine != null) {
            val isActive = limitManager.isRoutineActiveNow(routine)
            Log.d(TAG, "Routine ${routine.name} active: $isActive")

            // If routine is not active now (wrong day/time), skip all limits
            if (!isActive) {
                exceededAppsCache.remove(packageName)
                return CheckResult.RoutineInactive
            }

            exceededAppsCache[packageName]?.let { cached ->
                return CheckResult.LimitExceeded(cached.usedSeconds, cached.limitSeconds, cached.openCount)
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
            exceededAppsCache.remove(packageName)
            return CheckResult.NoLimit
        }

        exceededAppsCache[packageName]?.let { cached ->
            return CheckResult.LimitExceeded(cached.usedSeconds, cached.limitSeconds, cached.openCount)
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
            return CheckResult.LimitExceeded(usageTodaySeconds, config.dailyLimitSeconds, openingsToday)
        }

        return CheckResult.WithinLimit
    }

    fun handleLimitExceeded(packageName: String, usedSeconds: Int, limitSeconds: Int, openCount: Int) {
        exceededAppsCache[packageName] = CachedLimitResult(usedSeconds, limitSeconds, openCount)

        val currentTime = System.currentTimeMillis()
        val lastShownTime = lastOverlayShownTime[packageName] ?: 0L
        val timeSinceLastOverlay = currentTime - lastShownTime

        if (timeSinceLastOverlay >= OVERLAY_DEBOUNCE_MS) {
            lastOverlayShownTime[packageName] = currentTime

            Log.d(TAG, "Showing overlay for $packageName (timeSinceLastOverlay=${timeSinceLastOverlay}ms)")

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
        } else {
            Log.d(TAG, "Skipping overlay for $packageName - shown ${timeSinceLastOverlay}ms ago (debounce: ${OVERLAY_DEBOUNCE_MS}ms)")
        }
    }

    fun onAppChanged(newPackageName: String) {
        val keysToRemove = lastOverlayShownTime.keys.filter { it != newPackageName }
        keysToRemove.forEach { lastOverlayShownTime.remove(it) }
    }
}
