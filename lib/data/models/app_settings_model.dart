import 'package:hive_ce/hive.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 2)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  bool monitoringEnabled;

  @HiveField(1)
  bool notificationsEnabled;

  @HiveField(2)
  bool onboardingCompleted;

  @HiveField(3)
  int themeMode; // 0 = system, 1 = light, 2 = dark

  AppSettingsModel({
    this.monitoringEnabled = true,
    this.notificationsEnabled = true,
    this.onboardingCompleted = false,
    this.themeMode = 0,
  });
}
