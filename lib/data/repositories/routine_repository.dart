import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine_model.dart';
import '../../domain/entities/routine.dart';

class RoutineRepository {
  static const String _boxName = 'routines';
  static const String _sharedPrefsKey = 'routines_json';
  late Box<RoutineModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<RoutineModel>(_boxName);
    await _syncToSharedPreferences();
  }

  List<Routine> getAllRoutines() {
    return _box.values.map((model) => model.toEntity()).toList();
  }

  List<Routine> getActiveRoutines() {
    return _box.values
        .where((model) => !model.isArchived)
        .map((model) => model.toEntity())
        .toList();
  }

  List<Routine> getArchivedRoutines() {
    return _box.values
        .where((model) => model.isArchived)
        .map((model) => model.toEntity())
        .toList();
  }

  Routine? getRoutine(String id) {
    final model = _box.get(id);
    return model?.toEntity();
  }

  Future<void> saveRoutine(Routine routine) async {
    final model = RoutineModel.fromEntity(routine);
    await _box.put(routine.id, model);
    await _syncToSharedPreferences();
  }

  Future<void> deleteRoutine(String id) async {
    await _box.delete(id);
    await _syncToSharedPreferences();
  }

  Future<void> toggleRoutine(String id, bool enabled) async {
    final model = _box.get(id);
    if (model != null) {
      model.isEnabled = enabled;
      await model.save();
      await _syncToSharedPreferences();
    }
  }

  Future<void> archiveRoutine(String id) async {
    final model = _box.get(id);
    if (model != null) {
      model.isArchived = true;
      model.isEnabled = false;
      await model.save();
      await _syncToSharedPreferences();
    }
  }

  Future<void> restoreRoutine(String id) async {
    final model = _box.get(id);
    if (model != null) {
      model.isArchived = false;
      await model.save();
      await _syncToSharedPreferences();
    }
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _syncToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final routines = getAllRoutines();
      final routinesJson = routines.map((routine) => {
        'id': routine.id,
        'name': routine.name,
        'days': routine.days.toList(),
        'appPackages': routine.appPackages.toList(),
        'isEnabled': routine.isEnabled,
        'isArchived': routine.isArchived,
        'startTime': routine.startTime,
        'endTime': routine.endTime,
        'dailyLimitSeconds': routine.dailyLimit.inSeconds,
        'dailyLimitOpenings': routine.dailyLimitOpenings,
        'overlayColor': routine.overlayColor,
        'overlayIcon': routine.overlayIcon,
      }).toList();
      await prefs.setString(_sharedPrefsKey, jsonEncode(routinesJson));
    } catch (e) {
      // Silently fail
    }
  }
}
