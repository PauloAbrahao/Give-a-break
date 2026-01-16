import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/routine_repository.dart';
import '../../domain/entities/routine.dart';

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

final routineProvider =
    FutureProvider.family<Routine?, String>((ref, id) async {
  final repo = await ref.watch(routineRepositoryProvider.future);
  return repo.getRoutine(id);
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
    state = AsyncValue.data(_repository.getAllRoutines());
    _ref.invalidate(allRoutinesProvider);
    _ref.invalidate(routineProvider(routine.id));
  }

  Future<void> deleteRoutine(String id) async {
    if (_repository == null) return;
    await _repository.deleteRoutine(id);
    state = AsyncValue.data(_repository.getAllRoutines());
    _ref.invalidate(allRoutinesProvider);
    _ref.invalidate(routineProvider(id));
  }

  Future<void> toggleRoutine(String id, bool enabled) async {
    if (_repository == null) return;
    await _repository.toggleRoutine(id, enabled);
    state = AsyncValue.data(_repository.getAllRoutines());
    _ref.invalidate(allRoutinesProvider);
    _ref.invalidate(routineProvider(id));
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
