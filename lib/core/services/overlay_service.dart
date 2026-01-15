import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlayService {
  OverlayService._();

  // Keys for shared preferences
  static const String _keyAppName = 'overlay_app_name';
  static const String _keyUsedTime = 'overlay_used_time';
  static const String _keyLimitTime = 'overlay_limit_time';

  static Future<bool> isPermissionGranted() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  static Future<void> requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }

  static Future<void> showOverlay({
    required String appName,
    required String usedTime,
    required String limitTime,
  }) async {
    final hasPermission = await isPermissionGranted();
    if (!hasPermission) return;

    // Save data for overlay to read
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppName, appName);
    await prefs.setString(_keyUsedTime, usedTime);
    await prefs.setString(_keyLimitTime, limitTime);

    final isActive = await FlutterOverlayWindow.isActive();
    if (isActive) {
      await FlutterOverlayWindow.closeOverlay();
    }

    await FlutterOverlayWindow.showOverlay(
      enableDrag: false,
      overlayTitle: 'Give a Break',
      overlayContent: 'Time limit reached for $appName',
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      height: WindowSize.matchParent,
      width: WindowSize.matchParent,
    );
  }

  static Future<Map<String, String>> getOverlayData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'appName': prefs.getString(_keyAppName) ?? 'App',
      'usedTime': prefs.getString(_keyUsedTime) ?? '--',
      'limitTime': prefs.getString(_keyLimitTime) ?? '--',
    };
  }

  static Future<void> closeOverlay() async {
    final isActive = await FlutterOverlayWindow.isActive();
    if (isActive) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  static Future<bool> isOverlayActive() async {
    return await FlutterOverlayWindow.isActive();
  }
}
