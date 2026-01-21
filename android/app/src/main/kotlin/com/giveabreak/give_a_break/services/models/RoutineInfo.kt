package com.giveabreak.give_a_break.services.models

data class RoutineInfo(
    val id: String,
    val name: String,
    val days: List<Int>,
    val appPackages: List<String>,
    val isEnabled: Boolean,
    val isArchived: Boolean,
    val startTime: String?,
    val endTime: String?,
    val dailyLimitSeconds: Int,
    val dailyLimitOpenings: Int
)
