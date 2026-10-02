package com.giveabreak.give_a_break.services

import android.content.Context
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import com.giveabreak.give_a_break.services.models.AppUsageToday
import java.util.Calendar
import java.util.concurrent.ConcurrentHashMap

class LimitChecker(context: Context, private val overlay: LimitOverlay) {

    companion object {
        private const val TAG = "LimitChecker"
        private const val OVERLAY_DEBOUNCE_MS = 2000L
        private const val USAGE_FLUSH_DELAY_MS = 1000L
        private const val MILLIS_PER_SECOND = 1000L
        private const val WORKER_THREAD_NAME = "LimitCheckerWorker"
    }

    private val usageStatsHelper = UsageStatsHelper(context)
    private val limitManager = LimitManager(context) { refreshAllUsage() }

    private val workerThread = HandlerThread(WORKER_THREAD_NAME).apply { start() }
    private val workerHandler = Handler(workerThread.looper)
    private val mainHandler = Handler(Looper.getMainLooper())

    private val lastOverlayShownTime = mutableMapOf<String, Long>()
    private val usageCache = ConcurrentHashMap<String, AppUsageToday>()
    private var cacheDate = currentDayOfYear()

    private var foregroundPackage: String? = null
    private var foregroundUsage: AppUsageToday? = null
    private val limitReachedRunnable = Runnable { onForegroundLimitReached() }

    private data class LimitConfig(
        val dailyLimitSeconds: Int,
        val dailyLimitOpenings: Int
    ) {
        val dailyLimitMillis: Long get() = dailyLimitSeconds * MILLIS_PER_SECOND
    }

    init {
        refreshAllUsage()
    }

    fun onAppOpened(packageName: String) {
        clearCacheIfNewDay()

        val config = getActiveLimitConfig(packageName) ?: return

        val cached = usageCache[packageName]
        if (cached != null) {
            val usageWithThisOpen = cached.copy(openCount = cached.openCount + 1)
            usageCache[packageName] = usageWithThisOpen
            if (applyUsage(packageName, config, usageWithThisOpen)) return
        }

        workerHandler.post { verifyOpenedApp(packageName) }
    }

    fun onAppChanged(newPackageName: String) {
        val previousPackage = foregroundPackage
        foregroundPackage = newPackageName
        foregroundUsage = null
        mainHandler.removeCallbacks(limitReachedRunnable)

        lastOverlayShownTime.keys.retainAll { it == newPackageName }

        if (previousPackage == null || previousPackage == newPackageName) return
        workerHandler.postDelayed({ refreshUsage(setOf(previousPackage)) }, USAGE_FLUSH_DELAY_MS)
    }

    fun release() {
        limitManager.release()
        mainHandler.removeCallbacksAndMessages(null)
        workerThread.quitSafely()
    }

    private fun applyUsage(packageName: String, config: LimitConfig, usage: AppUsageToday): Boolean {
        foregroundUsage = usage

        if (isLimitExceeded(config, usage)) {
            mainHandler.removeCallbacks(limitReachedRunnable)
            showOverlay(packageName, config, usage)
            return true
        }

        scheduleLimitReached(config, usage)
        return false
    }

    private fun scheduleLimitReached(config: LimitConfig, usage: AppUsageToday) {
        mainHandler.removeCallbacks(limitReachedRunnable)
        if (config.dailyLimitSeconds <= 0) return

        val remainingMillis = config.dailyLimitMillis - usage.usedMillis
        mainHandler.postDelayed(limitReachedRunnable, remainingMillis)
    }

    private fun onForegroundLimitReached() {
        val packageName = foregroundPackage ?: return
        val config = getActiveLimitConfig(packageName) ?: return
        val openCount = foregroundUsage?.openCount ?: 0

        showOverlay(packageName, config, AppUsageToday(config.dailyLimitMillis, openCount))
    }

    private fun verifyOpenedApp(packageName: String) {
        val usage = refreshUsage(setOf(packageName))[packageName] ?: return

        mainHandler.post {
            if (foregroundPackage != packageName) return@post
            val config = getActiveLimitConfig(packageName) ?: return@post
            try {
                applyUsage(packageName, config, usage)
            } catch (e: Exception) {
                Log.e(TAG, "Error showing overlay for $packageName: ${e.message}", e)
            }
        }
    }

    private fun refreshAllUsage() {
        workerHandler.post {
            val limitedPackages = limitManager.getLimitedPackages()
            usageCache.keys.retainAll(limitedPackages)
            refreshUsage(limitedPackages)
        }
    }

    private fun refreshUsage(packageNames: Set<String>): Map<String, AppUsageToday> {
        return try {
            usageStatsHelper.getUsageToday(packageNames).also { usageCache.putAll(it) }
        } catch (e: Exception) {
            Log.e(TAG, "Error reading usage for $packageNames: ${e.message}", e)
            emptyMap()
        }
    }

    private fun isLimitExceeded(config: LimitConfig, usage: AppUsageToday): Boolean {
        val timeLimitReached = config.dailyLimitSeconds > 0 &&
                               usage.usedMillis >= config.dailyLimitMillis
        val openingsLimitReached = config.dailyLimitOpenings > 0 &&
                                   usage.openCount >= config.dailyLimitOpenings
        return timeLimitReached || openingsLimitReached
    }

    private fun getActiveLimitConfig(packageName: String): LimitConfig? {
        val routine = limitManager.getRoutineForApp(packageName)
        if (routine != null) {
            if (!limitManager.isRoutineActiveNow(routine)) return null
            return LimitConfig(routine.dailyLimitSeconds, routine.dailyLimitOpenings)
        }

        val limit = limitManager.getAppLimit(packageName) ?: return null
        if (!limit.isEnabled) return null
        return LimitConfig(limit.dailyLimitSeconds, limit.dailyLimitOpenings)
    }

    private fun clearCacheIfNewDay() {
        val today = currentDayOfYear()
        if (today == cacheDate) return

        cacheDate = today
        usageCache.clear()
        refreshAllUsage()
    }

    private fun currentDayOfYear(): Int = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)

    private fun showOverlay(packageName: String, config: LimitConfig, usage: AppUsageToday) {
        val currentTime = System.currentTimeMillis()
        val timeSinceLastOverlay = currentTime - (lastOverlayShownTime[packageName] ?: 0L)

        if (timeSinceLastOverlay < OVERLAY_DEBOUNCE_MS) {
            Log.d(TAG, "Skipping overlay for $packageName - shown ${timeSinceLastOverlay}ms ago (debounce: ${OVERLAY_DEBOUNCE_MS}ms)")
            return
        }

        lastOverlayShownTime[packageName] = currentTime
        Log.d(TAG, "Showing overlay for $packageName (timeSinceLastOverlay=${timeSinceLastOverlay}ms)")

        val routine = limitManager.getRoutineForApp(packageName)
        overlay.show(
            packageName,
            (usage.usedMillis / MILLIS_PER_SECOND).toInt(),
            config.dailyLimitSeconds,
            usage.openCount,
            routine?.overlayColor,
            routine?.overlayIcon
        )
    }
}
