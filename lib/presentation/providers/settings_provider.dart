import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';

final settingsRepositoryProvider =
    FutureProvider<SettingsRepository>((ref) async {
  final repo = SettingsRepository();
  await repo.init();
  return repo;
});

final monitoringEnabledProvider = FutureProvider<bool>((ref) async {
  final repo = await ref.watch(settingsRepositoryProvider.future);
  return repo.isMonitoringEnabled;
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final repo = await ref.watch(settingsRepositoryProvider.future);
  return repo.isOnboardingCompleted;
});

final themeModeProvider = FutureProvider<int>((ref) async {
  final repo = await ref.watch(settingsRepositoryProvider.future);
  return repo.themeMode;
});

class SettingsNotifier extends StateNotifier<void> {
  final SettingsRepository _repository;
  final Ref _ref;

  SettingsNotifier(this._repository, this._ref) : super(null);

  Future<void> setMonitoringEnabled(bool enabled) async {
    await _repository.setMonitoringEnabled(enabled);
    _ref.invalidate(monitoringEnabledProvider);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _repository.setOnboardingCompleted(completed);
    _ref.invalidate(onboardingCompletedProvider);
  }

  Future<void> setThemeMode(int mode) async {
    await _repository.setThemeMode(mode);
    _ref.invalidate(themeModeProvider);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, void>((ref) {
  final repoAsync = ref.watch(settingsRepositoryProvider);
  return repoAsync.when(
    data: (repo) => SettingsNotifier(repo, ref),
    loading: () => SettingsNotifier(SettingsRepository(), ref),
    error: (_, __) => SettingsNotifier(SettingsRepository(), ref),
  );
});
