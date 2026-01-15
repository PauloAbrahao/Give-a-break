import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/app_limit_repository.dart';
import '../../domain/entities/app_limit.dart';

final appLimitRepositoryProvider =
    FutureProvider<AppLimitRepository>((ref) async {
  final repo = AppLimitRepository();
  await repo.init();
  return repo;
});

final allLimitsProvider = FutureProvider<List<AppLimit>>((ref) async {
  final repo = await ref.watch(appLimitRepositoryProvider.future);
  return repo.getAllLimits();
});

final appLimitProvider =
    FutureProvider.family<AppLimit?, String>((ref, packageName) async {
  final repo = await ref.watch(appLimitRepositoryProvider.future);
  return repo.getLimit(packageName);
});

class AppLimitNotifier extends StateNotifier<AsyncValue<List<AppLimit>>> {
  final AppLimitRepository? _repository;
  final Ref _ref;

  AppLimitNotifier(AppLimitRepository repository, this._ref)
      : _repository = repository,
        super(AsyncValue.data(repository.getAllLimits()));

  AppLimitNotifier._empty(this._ref)
      : _repository = null,
        super(const AsyncValue.loading());

  Future<void> setLimit(AppLimit limit) async {
    if (_repository == null) return;
    await _repository.setLimit(limit);
    state = AsyncValue.data(_repository.getAllLimits());
    _ref.invalidate(allLimitsProvider);
    _ref.invalidate(appLimitProvider(limit.packageName));
  }

  Future<void> removeLimit(String packageName) async {
    if (_repository == null) return;
    await _repository.removeLimit(packageName);
    state = AsyncValue.data(_repository.getAllLimits());
    _ref.invalidate(allLimitsProvider);
    _ref.invalidate(appLimitProvider(packageName));
  }

  Future<void> toggleLimit(String packageName, bool enabled) async {
    if (_repository == null) return;
    await _repository.toggleLimit(packageName, enabled);
    state = AsyncValue.data(_repository.getAllLimits());
    _ref.invalidate(allLimitsProvider);
    _ref.invalidate(appLimitProvider(packageName));
  }

  Future<void> updateLastWarning(String packageName) async {
    if (_repository == null) return;
    await _repository.updateLastWarning(packageName, DateTime.now());
    _ref.invalidate(appLimitProvider(packageName));
  }
}

final appLimitNotifierProvider =
    StateNotifierProvider<AppLimitNotifier, AsyncValue<List<AppLimit>>>((ref) {
  final repoAsync = ref.watch(appLimitRepositoryProvider);
  return repoAsync.when(
    data: (repo) => AppLimitNotifier(repo, ref),
    loading: () => AppLimitNotifier._empty(ref),
    error: (_, __) => AppLimitNotifier._empty(ref),
  );
});
