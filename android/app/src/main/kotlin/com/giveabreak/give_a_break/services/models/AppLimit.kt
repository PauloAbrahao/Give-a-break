package com.giveabreak.give_a_break.services.models

data class AppLimit(
    val packageName: String,
    val dailyLimitSeconds: Int,
    val dailyLimitOpenings: Int = 0,
    val isEnabled: Boolean
)
