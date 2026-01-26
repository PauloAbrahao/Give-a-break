import 'package:flutter/services.dart';

class MethodChannelService {
  MethodChannelService._();

  static const _usageStatsChannel =
      MethodChannel('com.giveabreak/usage_stats');
  static const _overlayChannel = MethodChannel('com.giveabreak/overlay');
  static const _monitorChannel =
      MethodChannel('com.giveabreak/monitor_service');

  // Usage Stats Methods
  static Future<bool> checkUsageStatsPermission() async {
    try {
      final result =
          await _usageStatsChannel.invokeMethod<bool>('checkPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestUsageStatsPermission() async {
    try {
      await _usageStatsChannel.invokeMethod('requestPermission');
    } on PlatformException {
      // Permission request opened settings
    }
  }

  static Future<List<Map<String, dynamic>>> getUsageStats({
    required int startTime,
    required int endTime,
  }) async {
    try {
      final result = await _usageStatsChannel.invokeMethod<List<dynamic>>(
        'getUsageStats',
        {'startTime': startTime, 'endTime': endTime},
      );
      if (result == null) return [];
      return result.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    } on PlatformException {
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<String?> getForegroundApp() async {
    try {
      final result =
          await _usageStatsChannel.invokeMethod<String>('getForegroundApp');
      return result;
    } on PlatformException {
      return null;
    }
  }

  // Overlay Methods
  static Future<bool> checkOverlayPermission() async {
    try {
      final result =
          await _overlayChannel.invokeMethod<bool>('checkPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    try {
      await _overlayChannel.invokeMethod('requestPermission');
    } on PlatformException {
      // Permission request opened settings
    }
  }

  // Monitor Service Methods
  static Future<void> startMonitorService() async {
    try {
      await _monitorChannel.invokeMethod('startService');
    } on PlatformException {
      // Service start failed
    }
  }

  static Future<void> stopMonitorService() async {
    try {
      await _monitorChannel.invokeMethod('stopService');
    } on PlatformException {
      // Service stop failed
    }
  }

  static Future<bool> isMonitorServiceRunning() async {
    try {
      final result =
          await _monitorChannel.invokeMethod<bool>('isServiceRunning');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  // Accessibility Service Methods
  static Future<bool> checkAccessibilityPermission() async {
    try {
      final result =
          await _monitorChannel.invokeMethod<bool>('checkAccessibilityPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestAccessibilityPermission() async {
    try {
      await _monitorChannel.invokeMethod('requestAccessibilityPermission');
    } on PlatformException {
      // Permission request opened settings
    }
  }

  static Future<bool> isAccessibilityServiceRunning() async {
    try {
      final result =
          await _monitorChannel.invokeMethod<bool>('isAccessibilityServiceRunning');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> isMonitoringFullyFunctional() async {
    try {
      final result =
          await _monitorChannel.invokeMethod<bool>('isMonitoringFullyFunctional');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> needsAccessibilityReconnect() async {
    try {
      final result =
          await _monitorChannel.invokeMethod<bool>('needsAccessibilityReconnect');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
