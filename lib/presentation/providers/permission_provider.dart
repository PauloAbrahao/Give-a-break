import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/method_channel_service.dart';

class PermissionState {
  final bool usageStatsGranted;
  final bool accessibilityGranted;

  const PermissionState({
    this.usageStatsGranted = false,
    this.accessibilityGranted = false,
  });

  bool get coreGranted => usageStatsGranted && accessibilityGranted;

  PermissionState copyWith({
    bool? usageStatsGranted,
    bool? accessibilityGranted,
  }) {
    return PermissionState(
      usageStatsGranted: usageStatsGranted ?? this.usageStatsGranted,
      accessibilityGranted: accessibilityGranted ?? this.accessibilityGranted,
    );
  }
}

class PermissionNotifier extends StateNotifier<PermissionState> {
  PermissionNotifier() : super(const PermissionState());

  Future<void> checkAllPermissions() async {
    final usageStats = await MethodChannelService.checkUsageStatsPermission();
    final accessibility = await MethodChannelService.checkAccessibilityPermission();

    state = PermissionState(
      usageStatsGranted: usageStats,
      accessibilityGranted: accessibility,
    );
  }

  Future<void> requestUsageStatsPermission() async {
    await MethodChannelService.requestUsageStatsPermission();
  }

  Future<void> requestAccessibilityPermission() async {
    await MethodChannelService.requestAccessibilityPermission();
  }
}

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>(
  (ref) => PermissionNotifier(),
);
