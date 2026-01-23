import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/method_channel_service.dart';

class PermissionState {
  final bool usageStatsGranted;
  final bool overlayGranted;
  final bool notificationGranted;
  final bool accessibilityGranted;

  const PermissionState({
    this.usageStatsGranted = false,
    this.overlayGranted = false,
    this.notificationGranted = false,
    this.accessibilityGranted = false,
  });

  bool get allGranted =>
      usageStatsGranted && overlayGranted && notificationGranted && accessibilityGranted;

  bool get coreGranted => usageStatsGranted && overlayGranted && accessibilityGranted;

  PermissionState copyWith({
    bool? usageStatsGranted,
    bool? overlayGranted,
    bool? notificationGranted,
    bool? accessibilityGranted,
  }) {
    return PermissionState(
      usageStatsGranted: usageStatsGranted ?? this.usageStatsGranted,
      overlayGranted: overlayGranted ?? this.overlayGranted,
      notificationGranted: notificationGranted ?? this.notificationGranted,
      accessibilityGranted: accessibilityGranted ?? this.accessibilityGranted,
    );
  }
}

class PermissionNotifier extends StateNotifier<PermissionState> {
  PermissionNotifier() : super(const PermissionState());

  Future<void> checkAllPermissions() async {
    final usageStats = await MethodChannelService.checkUsageStatsPermission();
    final overlay = await MethodChannelService.checkOverlayPermission();
    final notification = await Permission.notification.isGranted;
    final accessibility = await MethodChannelService.checkAccessibilityPermission();

    state = PermissionState(
      usageStatsGranted: usageStats,
      overlayGranted: overlay,
      notificationGranted: notification,
      accessibilityGranted: accessibility,
    );
  }

  Future<void> requestUsageStatsPermission() async {
    await MethodChannelService.requestUsageStatsPermission();
  }

  Future<void> requestOverlayPermission() async {
    await MethodChannelService.requestOverlayPermission();
  }

  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
    await checkAllPermissions();
  }

  Future<void> requestAccessibilityPermission() async {
    await MethodChannelService.requestAccessibilityPermission();
  }
}

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>(
  (ref) => PermissionNotifier(),
);
