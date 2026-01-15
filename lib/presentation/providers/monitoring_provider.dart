import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/method_channel_service.dart';
import '../../data/repositories/app_limit_repository.dart';
import '../../data/repositories/usage_repository.dart';
import 'app_limit_provider.dart';

class MonitoringState {
  final bool isRunning;
  final String? currentForegroundApp;
  final DateTime? lastCheck;

  const MonitoringState({
    this.isRunning = false,
    this.currentForegroundApp,
    this.lastCheck,
  });

  MonitoringState copyWith({
    bool? isRunning,
    String? currentForegroundApp,
    DateTime? lastCheck,
  }) {
    return MonitoringState(
      isRunning: isRunning ?? this.isRunning,
      currentForegroundApp: currentForegroundApp ?? this.currentForegroundApp,
      lastCheck: lastCheck ?? this.lastCheck,
    );
  }
}

class MonitoringNotifier extends StateNotifier<MonitoringState> {
  final Ref _ref;
  final UsageRepository _usageRepository;
  AppLimitRepository? _limitRepository;

  static const _callbackChannel =
      MethodChannel('com.giveabreak/monitor_callback');

  MonitoringNotifier(this._ref, this._usageRepository)
      : super(const MonitoringState()) {
    _initCallbackChannel();
    _initLimitRepository();
  }

  void _initCallbackChannel() {
    _callbackChannel.setMethodCallHandler(_handleCallback);
  }

  Future<void> _initLimitRepository() async {
    final repoAsync = await _ref.read(appLimitRepositoryProvider.future);
    _limitRepository = repoAsync;
  }

  Future<dynamic> _handleCallback(MethodCall call) async {
    if (call.method == 'onAppForeground') {
      final args = call.arguments as Map<dynamic, dynamic>;
      final packageName = args['packageName'] as String;
      final timestamp = args['timestamp'] as int;

      state = state.copyWith(
        currentForegroundApp: packageName,
        lastCheck: DateTime.fromMillisecondsSinceEpoch(timestamp),
      );

      await _checkLimitForApp(packageName);
    }
  }

  Future<void> _checkLimitForApp(String packageName) async {
    if (_limitRepository == null) return;

    final limit = _limitRepository!.getLimit(packageName);
    if (limit == null || !limit.isEnabled) return;

    final usageToday = await _usageRepository.getAppUsageToday(packageName);
    final dailyLimit = limit.dailyLimit;

    // Check if over limit
    if (usageToday >= dailyLimit) {
      // Check cooldown
      if (limit.lastWarningShown != null) {
        final timeSinceWarning =
            DateTime.now().difference(limit.lastWarningShown!);
        if (timeSinceWarning < limit.cooldownPeriod) {
          return; // Still in cooldown
        }
      }

      // Update last warning time
      await _limitRepository!.updateLastWarning(packageName, DateTime.now());

      // Trigger overlay (will be implemented in overlay provider)
      _ref.read(overlayTriggerProvider.notifier).triggerOverlay(
            packageName: packageName,
            usedTime: usageToday,
            limitTime: dailyLimit,
          );
    }
  }

  Future<void> startMonitoring() async {
    await MethodChannelService.startMonitorService();
    state = state.copyWith(isRunning: true);
  }

  Future<void> stopMonitoring() async {
    await MethodChannelService.stopMonitorService();
    state = state.copyWith(isRunning: false);
  }

  Future<void> checkServiceStatus() async {
    final isRunning = await MethodChannelService.isMonitorServiceRunning();
    state = state.copyWith(isRunning: isRunning);
  }
}

final monitoringProvider =
    StateNotifierProvider<MonitoringNotifier, MonitoringState>((ref) {
  final usageRepo = UsageRepository();
  return MonitoringNotifier(ref, usageRepo);
});

// Overlay trigger state
class OverlayTriggerState {
  final bool shouldShow;
  final String? packageName;
  final Duration? usedTime;
  final Duration? limitTime;

  const OverlayTriggerState({
    this.shouldShow = false,
    this.packageName,
    this.usedTime,
    this.limitTime,
  });

  OverlayTriggerState copyWith({
    bool? shouldShow,
    String? packageName,
    Duration? usedTime,
    Duration? limitTime,
  }) {
    return OverlayTriggerState(
      shouldShow: shouldShow ?? this.shouldShow,
      packageName: packageName ?? this.packageName,
      usedTime: usedTime ?? this.usedTime,
      limitTime: limitTime ?? this.limitTime,
    );
  }
}

class OverlayTriggerNotifier extends StateNotifier<OverlayTriggerState> {
  OverlayTriggerNotifier() : super(const OverlayTriggerState());

  void triggerOverlay({
    required String packageName,
    required Duration usedTime,
    required Duration limitTime,
  }) {
    state = OverlayTriggerState(
      shouldShow: true,
      packageName: packageName,
      usedTime: usedTime,
      limitTime: limitTime,
    );
  }

  void dismissOverlay() {
    state = const OverlayTriggerState(shouldShow: false);
  }
}

final overlayTriggerProvider =
    StateNotifierProvider<OverlayTriggerNotifier, OverlayTriggerState>(
  (ref) => OverlayTriggerNotifier(),
);
