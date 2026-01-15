import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final _notifications = FlutterLocalNotificationsPlugin();

  static const _warningChannelId = 'usage_warnings';
  static const _warningChannelName = 'Usage Warnings';
  static const _warningChannelDesc = 'Notifications for app usage warnings';

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _warningChannelId,
      _warningChannelName,
      description: _warningChannelDesc,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
  }

  static Future<void> showUsageWarning({
    required String appName,
    required String usedTime,
    required String limitTime,
    required int thresholdPercent,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _warningChannelId,
      _warningChannelName,
      channelDescription: _warningChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      appName.hashCode, // Unique ID per app
      'Usage Warning: $appName',
      'You\'ve used $usedTime of your $limitTime limit ($thresholdPercent%)',
      details,
    );
  }

  static Future<void> showLimitReached({
    required String appName,
    required String usedTime,
    required String limitTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _warningChannelId,
      _warningChannelName,
      channelDescription: _warningChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      appName.hashCode + 1000, // Different ID for limit notifications
      'Time\'s Up: $appName',
      'You\'ve reached your daily limit of $limitTime',
      details,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
