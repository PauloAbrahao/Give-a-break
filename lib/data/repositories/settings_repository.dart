import 'package:hive_ce/hive.dart';
import '../models/app_settings_model.dart';

class SettingsRepository {
  static const String _settingsBoxName = 'app_settings';
  static const String _settingsKey = 'settings';

  late Box<AppSettingsModel> _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox<AppSettingsModel>(_settingsBoxName);

    // Initialize with defaults if empty
    if (!_settingsBox.containsKey(_settingsKey)) {
      await _settingsBox.put(_settingsKey, AppSettingsModel());
    }
  }

  AppSettingsModel get settings =>
      _settingsBox.get(_settingsKey) ?? AppSettingsModel();

  // App Settings
  Future<void> setMonitoringEnabled(bool enabled) async {
    final current = settings;
    current.monitoringEnabled = enabled;
    await current.save();
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final current = settings;
    current.onboardingCompleted = completed;
    await current.save();
  }

  bool get isMonitoringEnabled => settings.monitoringEnabled;
  bool get isNotificationsEnabled => settings.notificationsEnabled;
  bool get isOnboardingCompleted => settings.onboardingCompleted;
  int get themeMode => settings.themeMode;

  Future<void> setThemeMode(int mode) async {
    final current = settings;
    current.themeMode = mode;
    await current.save();
  }
}
