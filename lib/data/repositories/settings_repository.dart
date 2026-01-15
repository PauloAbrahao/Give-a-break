import 'package:hive_ce/hive.dart';
import '../models/app_settings_model.dart';
import '../models/parental_settings_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SettingsRepository {
  static const String _settingsBoxName = 'app_settings';
  static const String _parentalBoxName = 'parental_settings';
  static const String _settingsKey = 'settings';
  static const String _parentalKey = 'parental';

  late Box<AppSettingsModel> _settingsBox;
  late Box<ParentalSettingsModel> _parentalBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox<AppSettingsModel>(_settingsBoxName);
    _parentalBox = await Hive.openBox<ParentalSettingsModel>(_parentalBoxName);

    // Initialize with defaults if empty
    if (!_settingsBox.containsKey(_settingsKey)) {
      await _settingsBox.put(_settingsKey, AppSettingsModel());
    }
    if (!_parentalBox.containsKey(_parentalKey)) {
      await _parentalBox.put(_parentalKey, ParentalSettingsModel());
    }
  }

  AppSettingsModel get settings =>
      _settingsBox.get(_settingsKey) ?? AppSettingsModel();

  ParentalSettingsModel get parentalSettings =>
      _parentalBox.get(_parentalKey) ?? ParentalSettingsModel();

  // App Settings
  Future<void> setMonitoringEnabled(bool enabled) async {
    final current = settings;
    current.monitoringEnabled = enabled;
    await current.save();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final current = settings;
    current.notificationsEnabled = enabled;
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

  // Parental Settings
  Future<void> setParentalEnabled(bool enabled) async {
    final current = parentalSettings;
    current.isEnabled = enabled;
    await current.save();
  }

  Future<void> setPin(String pin) async {
    final current = parentalSettings;
    current.pinHash = _hashPin(pin);
    await current.save();
  }

  Future<void> removePin() async {
    final current = parentalSettings;
    current.pinHash = null;
    current.isEnabled = false;
    await current.save();
  }

  bool verifyPin(String pin) {
    final current = parentalSettings;
    if (current.pinHash == null) return false;
    return current.pinHash == _hashPin(pin);
  }

  bool get hasPin => parentalSettings.pinHash != null;
  bool get isParentalEnabled => parentalSettings.isEnabled;

  Future<void> setChildModeEnabled(bool enabled) async {
    final current = parentalSettings;
    current.childModeEnabled = enabled;
    await current.save();
  }

  bool get isChildModeEnabled => parentalSettings.childModeEnabled;

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
