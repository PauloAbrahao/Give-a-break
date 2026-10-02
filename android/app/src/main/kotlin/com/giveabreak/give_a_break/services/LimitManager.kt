package com.giveabreak.give_a_break.services

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.giveabreak.give_a_break.services.models.AppLimit
import com.giveabreak.give_a_break.services.models.RoutineInfo
import org.json.JSONArray
import java.util.Calendar

class LimitManager(
    context: Context,
    private val onLimitsChanged: () -> Unit
) {

    companion object {
        private const val TAG = "LimitManager"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val LIMITS_KEY = "flutter.app_limits_json"
        private const val ROUTINES_KEY = "flutter.routines_json"
    }

    private val sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    @Volatile
    private var appLimits: Map<String, AppLimit> = emptyMap()

    @Volatile
    private var routines: List<RoutineInfo> = emptyList()

    private val preferenceListener = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
        if (key != null && key != LIMITS_KEY && key != ROUTINES_KEY) return@OnSharedPreferenceChangeListener
        reload()
        onLimitsChanged()
    }

    init {
        reload()
        sharedPreferences.registerOnSharedPreferenceChangeListener(preferenceListener)
    }

    fun release() {
        sharedPreferences.unregisterOnSharedPreferenceChangeListener(preferenceListener)
    }

    fun getAppLimit(packageName: String): AppLimit? = appLimits[packageName]

    fun getRoutineForApp(packageName: String): RoutineInfo? =
        routines.firstOrNull { it.appPackages.contains(packageName) }

    fun getLimitedPackages(): Set<String> =
        appLimits.keys + routines.flatMap { it.appPackages }

    private fun reload() {
        appLimits = parseAppLimits()
        routines = parseRoutines()
    }

    private fun parseAppLimits(): Map<String, AppLimit> {
        return try {
            val limitsJson = sharedPreferences.getString(LIMITS_KEY, null) ?: return emptyMap()
            val jsonArray = JSONArray(limitsJson)

            (0 until jsonArray.length()).associate { i ->
                val obj = jsonArray.getJSONObject(i)
                val packageName = obj.getString("packageName")
                packageName to AppLimit(
                    packageName = packageName,
                    dailyLimitSeconds = obj.getInt("dailyLimitSeconds"),
                    dailyLimitOpenings = obj.optInt("dailyLimitOpenings", 0),
                    isEnabled = obj.getBoolean("isEnabled")
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing app limits: ${e.message}")
            emptyMap()
        }
    }

    private fun parseRoutines(): List<RoutineInfo> {
        return try {
            val routinesJson = sharedPreferences.getString(ROUTINES_KEY, null) ?: return emptyList()
            val jsonArray = JSONArray(routinesJson)

            (0 until jsonArray.length()).map { i ->
                val obj = jsonArray.getJSONObject(i)
                RoutineInfo(
                    id = obj.getString("id"),
                    name = obj.getString("name"),
                    days = parseIntArray(obj.getJSONArray("days")),
                    appPackages = parseStringArray(obj.getJSONArray("appPackages")),
                    isEnabled = obj.getBoolean("isEnabled"),
                    isArchived = obj.getBoolean("isArchived"),
                    startTime = obj.optString("startTime", null),
                    endTime = obj.optString("endTime", null),
                    dailyLimitSeconds = obj.optInt("dailyLimitSeconds", 0),
                    dailyLimitOpenings = obj.optInt("dailyLimitOpenings", 0),
                    overlayColor = if (obj.isNull("overlayColor")) null else obj.optString("overlayColor", null),
                    overlayIcon = if (obj.isNull("overlayIcon")) null else obj.optString("overlayIcon", null)
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing routines: ${e.message}")
            emptyList()
        }
    }

    fun isRoutineActiveNow(routine: RoutineInfo): Boolean {
        if (!routine.isEnabled || routine.isArchived) {
            return false
        }

        if (!isTodayInRoutineDays(routine.days)) {
            return false
        }

        if (!isCurrentTimeInRange(routine.startTime, routine.endTime)) {
            return false
        }

        return true
    }

    private fun isTodayInRoutineDays(days: List<Int>): Boolean {
        val calendar = Calendar.getInstance()
        val dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK)
        // Convert from Calendar (Sun=1) to Flutter format (Mon=1, Sun=7)
        val flutterDay = if (dayOfWeek == Calendar.SUNDAY) 7 else dayOfWeek - 1
        return days.contains(flutterDay)
    }

    private fun isCurrentTimeInRange(startTime: String?, endTime: String?): Boolean {
        if (startTime.isNullOrEmpty() || endTime.isNullOrEmpty()) {
            return true // No time restriction
        }

        val calendar = Calendar.getInstance()
        val currentMinutes = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)

        val startMinutes = parseTimeToMinutes(startTime) ?: return true
        val endMinutes = parseTimeToMinutes(endTime) ?: return true

        return if (startMinutes <= endMinutes) {
            // Normal range (e.g., 09:00 to 18:00)
            currentMinutes >= startMinutes && currentMinutes < endMinutes
        } else {
            // Overnight range (e.g., 22:00 to 06:00)
            currentMinutes >= startMinutes || currentMinutes < endMinutes
        }
    }

    private fun parseTimeToMinutes(time: String): Int? {
        val parts = time.split(":")
        if (parts.size != 2) return null
        val hours = parts[0].toIntOrNull() ?: return null
        val minutes = parts[1].toIntOrNull() ?: return null
        return hours * 60 + minutes
    }

    private fun parseStringArray(jsonArray: JSONArray): List<String> {
        return (0 until jsonArray.length()).map { jsonArray.getString(it) }
    }

    private fun parseIntArray(jsonArray: JSONArray): List<Int> {
        return (0 until jsonArray.length()).map { jsonArray.getInt(it) }
    }
}
