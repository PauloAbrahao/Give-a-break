package com.giveabreak.give_a_break

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.giveabreak.give_a_break.channels.UsageStatsChannel
import com.giveabreak.give_a_break.channels.MonitorServiceChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        UsageStatsChannel.register(this, flutterEngine.dartExecutor.binaryMessenger)
        MonitorServiceChannel.register(this, flutterEngine.dartExecutor.binaryMessenger)
    }
}
