import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_limit_model.dart';
import '../../domain/entities/app_limit.dart';

class AppLimitRepository {
  static const String _boxName = 'app_limits';
  static const String _sharedPrefsKey = 'app_limits_json';
  late Box<AppLimitModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<AppLimitModel>(_boxName);
    // Sync to SharedPreferences for Android service access
    await _syncToSharedPreferences();
  }

  List<AppLimit> getAllLimits() {
    return _box.values.map((model) => model.toEntity()).toList();
  }

  AppLimit? getLimit(String packageName) {
    final model = _box.get(packageName);
    return model?.toEntity();
  }

  Future<void> setLimit(AppLimit limit) async {
    final model = AppLimitModel.fromEntity(limit);
    await _box.put(limit.packageName, model);
    await _syncToSharedPreferences();
  }

  Future<void> removeLimit(String packageName) async {
    await _box.delete(packageName);
    await _syncToSharedPreferences();
  }

  Future<void> toggleLimit(String packageName, bool enabled) async {
    final model = _box.get(packageName);
    if (model != null) {
      model.isEnabled = enabled;
      await model.save();
      await _syncToSharedPreferences();
    }
  }

  bool hasLimit(String packageName) {
    return _box.containsKey(packageName);
  }

  List<String> getPackagesWithLimits() {
    return _box.keys.cast<String>().toList();
  }

  /// Sync limits to SharedPreferences so Android service can read them
  Future<void> _syncToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final limits = getAllLimits();
      final limitsJson = limits.map((limit) => {
        'packageName': limit.packageName,
        'dailyLimitSeconds': limit.dailyLimit.inSeconds,
        'dailyLimitOpenings': limit.dailyLimitOpenings,
        'isEnabled': limit.isEnabled,
        'warningThreshold': limit.warningThreshold,
      }).toList();
      await prefs.setString(_sharedPrefsKey, jsonEncode(limitsJson));
    } catch (e) {
      // Silently fail
    }
  }
}
