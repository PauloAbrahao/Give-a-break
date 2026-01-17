import 'package:hive_ce/hive.dart';
import '../models/routine_model.dart';
import '../../domain/entities/routine.dart';

class RoutineRepository {
  static const String _boxName = 'routines';
  late Box<RoutineModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<RoutineModel>(_boxName);
  }

  List<Routine> getAllRoutines() {
    return _box.values.map((model) => model.toEntity()).toList();
  }

  Routine? getRoutine(String id) {
    final model = _box.get(id);
    return model?.toEntity();
  }

  Future<void> saveRoutine(Routine routine) async {
    final model = RoutineModel.fromEntity(routine);
    await _box.put(routine.id, model);
  }

  Future<void> deleteRoutine(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleRoutine(String id, bool enabled) async {
    final model = _box.get(id);
    if (model != null) {
      model.isEnabled = enabled;
      await model.save();
    }
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
