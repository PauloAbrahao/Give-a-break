import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/routine_repository.dart';
import '../../domain/entities/app_limit.dart';
import '../../domain/entities/routine.dart';
import 'app_limit_provider.dart';

final routineRepositoryProvider =
    FutureProvider<RoutineRepository>((ref) async {
  final repo = RoutineRepository();
  await repo.init();
  return repo;
});

final allRoutinesProvider = FutureProvider<List<Routine>>((ref) async {
  final repo = await ref.watch(routineRepositoryProvider.future);
  return repo.getAllRoutines();
});

final activeRoutinesProvider = FutureProvider<List<Routine>>((ref) async {
  final repo = await ref.watch(routineRepositoryProvider.future);
  return repo.getActiveRoutines();
});

final archivedRoutinesProvider = FutureProvider<List<Routine>>((ref) async {
  final repo = await ref.watch(routineRepositoryProvider.future);
  return repo.getArchivedRoutines();
});

class RoutineNotifier extends StateNotifier<AsyncValue<List<Routine>>> {
  final RoutineRepository? _repository;
  final Ref _ref;

  RoutineNotifier(RoutineRepository repository, this._ref)
      : _repository = repository,
        super(AsyncValue.data(repository.getAllRoutines()));

  RoutineNotifier._empty(this._ref)
      : _repository = null,
        super(const AsyncValue.loading());

  Future<void> saveRoutine(Routine routine) async {
    if (_repository == null) return;
    await _repository.saveRoutine(routine);
    await _syncAppLimitsFromRoutine(routine);
    _invalidateAll();
  }

  Future<void> _syncAppLimitsFromRoutine(Routine routine) async {
    if (!routine.isEnabled) return;

    final limitNotifier = _ref.read(appLimitNotifierProvider.notifier);
    for (final packageName in routine.appPackages) {
      final limit = AppLimit(
        packageName: packageName,
        dailyLimit: routine.dailyLimit,
        dailyLimitOpenings: routine.dailyLimitOpenings,
      );
      await limitNotifier.setLimit(limit);
    }
  }

  Future<void> deleteRoutine(String id) async {
    if (_repository == null) return;
    await _repository.deleteRoutine(id);
    _invalidateAll();
  }

  Future<void> toggleRoutine(String id, bool enabled) async {
    if (_repository == null) return;
    await _repository.toggleRoutine(id, enabled);
    if (enabled) {
      final routine = _repository.getRoutine(id);
      if (routine != null) {
        await _syncAppLimitsFromRoutine(routine);
      }
    }
    _invalidateAll();
  }

  Future<void> archiveRoutine(String id) async {
    if (_repository == null) return;
    await _repository.archiveRoutine(id);
    _invalidateAll();
  }

  Future<void> restoreRoutine(String id) async {
    if (_repository == null) return;
    await _repository.restoreRoutine(id);
    _invalidateAll();
  }

  void _invalidateAll() {
    if (_repository == null) return;
    state = AsyncValue.data(_repository.getAllRoutines());
    _ref.invalidate(allRoutinesProvider);
    _ref.invalidate(activeRoutinesProvider);
    _ref.invalidate(archivedRoutinesProvider);
  }

  String generateId() {
    return _repository?.generateId() ?? DateTime.now().millisecondsSinceEpoch.toString();
  }
}

final routineNotifierProvider =
    StateNotifierProvider<RoutineNotifier, AsyncValue<List<Routine>>>((ref) {
  final repoAsync = ref.watch(routineRepositoryProvider);
  return repoAsync.when(
    data: (repo) => RoutineNotifier(repo, ref),
    loading: () => RoutineNotifier._empty(ref),
    error: (_, __) => RoutineNotifier._empty(ref),
  );
});

final appActiveRoutineProvider =
    FutureProvider.family<Routine?, String>((ref, packageName) async {
  final routines = await ref.watch(activeRoutinesProvider.future);
  for (final routine in routines) {
    if (routine.isEnabled && routine.appPackages.contains(packageName)) {
      return routine;
    }
  }
  return null;
});
