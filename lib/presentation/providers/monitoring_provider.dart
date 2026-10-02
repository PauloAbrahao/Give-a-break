import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/method_channel_service.dart';

class MonitoringState {
  final bool isRunning;

  const MonitoringState({
    this.isRunning = false,
  });

  MonitoringState copyWith({
    bool? isRunning,
  }) {
    return MonitoringState(
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class MonitoringNotifier extends StateNotifier<MonitoringState> {
  MonitoringNotifier() : super(const MonitoringState());

  Future<void> checkServiceStatus() async {
    final isRunning = await MethodChannelService.isMonitorServiceRunning();
    state = state.copyWith(isRunning: isRunning);
  }
}

final monitoringProvider =
    StateNotifierProvider<MonitoringNotifier, MonitoringState>(
  (ref) => MonitoringNotifier(),
);
