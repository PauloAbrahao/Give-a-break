import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../domain/entities/app_limit.dart';
import '../../domain/entities/routine.dart';
import 'app_limit_provider.dart';
import 'routine_provider.dart';
import 'settings_provider.dart';

class DataTransferResult {
  final bool success;
  final String message;

  const DataTransferResult({
    required this.success,
    required this.message,
  });
}

class DataTransferNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  DataTransferNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<DataTransferResult> exportData() async {
    state = const AsyncValue.loading();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final limitRepo = await _ref.read(appLimitRepositoryProvider.future);
      final routineRepo = await _ref.read(routineRepositoryProvider.future);
      final settingsRepo = await _ref.read(settingsRepositoryProvider.future);

      final limits = limitRepo.getAllLimits();
      final routines = routineRepo.getAllRoutines();
      final themeMode = settingsRepo.themeMode;

      final exportData = {
        'version': packageInfo.version,
        'exportDate': DateTime.now().toIso8601String(),
        'limits': limits.map((limit) => _limitToJson(limit)).toList(),
        'routines': routines.map((routine) => _routineToJson(routine)).toList(),
        'settings': {
          'themeMode': themeMode,
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'give_a_break_backup_$timestamp.json';

      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save backup file',
        fileName: fileName,
        bytes: bytes,
      );

      if (savedPath == null) {
        state = const AsyncValue.data(null);
        return const DataTransferResult(
          success: false,
          message: 'Export cancelled',
        );
      }

      state = const AsyncValue.data(null);
      return const DataTransferResult(
        success: true,
        message: 'Backup saved successfully',
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return DataTransferResult(
        success: false,
        message: 'Export failed: ${e.toString()}',
      );
    }
  }

  Future<DataTransferResult> importData() async {
    state = const AsyncValue.loading();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        state = const AsyncValue.data(null);
        return const DataTransferResult(
          success: false,
          message: 'No file selected',
        );
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final version = data['version'];
      if (version == null) {
        state = const AsyncValue.data(null);
        return const DataTransferResult(
          success: false,
          message: 'Invalid backup file',
        );
      }

      final limitRepo = await _ref.read(appLimitRepositoryProvider.future);
      final routineRepo = await _ref.read(routineRepositoryProvider.future);
      final settingsRepo = await _ref.read(settingsRepositoryProvider.future);

      // Import limits
      final limitsData = data['limits'] as List<dynamic>?;
      if (limitsData != null) {
        for (final limitJson in limitsData) {
          final limit = _limitFromJson(limitJson as Map<String, dynamic>);
          await limitRepo.setLimit(limit);
        }
      }

      // Import routines
      final routinesData = data['routines'] as List<dynamic>?;
      if (routinesData != null) {
        for (final routineJson in routinesData) {
          final routine = _routineFromJson(routineJson as Map<String, dynamic>);
          await routineRepo.saveRoutine(routine);
        }
      }

      // Import settings
      final settingsData = data['settings'] as Map<String, dynamic>?;
      if (settingsData != null) {
        final themeMode = settingsData['themeMode'] as int?;
        if (themeMode != null) {
          await settingsRepo.setThemeMode(themeMode);
        }
      }

      // Invalidate all providers to refresh data
      _ref.invalidate(appLimitRepositoryProvider);
      _ref.invalidate(appLimitNotifierProvider);
      _ref.invalidate(allLimitsProvider);
      _ref.invalidate(routineRepositoryProvider);
      _ref.invalidate(routineNotifierProvider);
      _ref.invalidate(allRoutinesProvider);
      _ref.invalidate(settingsRepositoryProvider);
      _ref.invalidate(themeModeProvider);

      state = const AsyncValue.data(null);
      return const DataTransferResult(
        success: true,
        message: 'Backup imported successfully',
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return DataTransferResult(
        success: false,
        message: 'Import failed: ${e.toString()}',
      );
    }
  }

  Map<String, dynamic> _limitToJson(AppLimit limit) {
    return {
      'packageName': limit.packageName,
      'dailyLimitMinutes': limit.dailyLimit.inMinutes,
      'warningThreshold': limit.warningThreshold,
      'isEnabled': limit.isEnabled,
    };
  }

  AppLimit _limitFromJson(Map<String, dynamic> json) {
    return AppLimit(
      packageName: json['packageName'] as String,
      dailyLimit: Duration(minutes: json['dailyLimitMinutes'] as int),
      warningThreshold: (json['warningThreshold'] as num).toDouble(),
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _routineToJson(Routine routine) {
    return {
      'id': routine.id,
      'name': routine.name,
      'description': routine.description,
      'days': routine.days.toList(),
      'appPackages': routine.appPackages.toList(),
      'isEnabled': routine.isEnabled,
      'createdAt': routine.createdAt?.toIso8601String(),
    };
  }

  Routine _routineFromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      days: (json['days'] as List<dynamic>).map((e) => e as int).toSet(),
      appPackages:
          (json['appPackages'] as List<dynamic>).map((e) => e as String).toSet(),
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

final dataTransferProvider =
    StateNotifierProvider<DataTransferNotifier, AsyncValue<void>>((ref) {
  return DataTransferNotifier(ref);
});
