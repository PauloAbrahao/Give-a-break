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

  AppSettingsModel({
    this.monitoringEnabled = false,
    this.notificationsEnabled = true,
    this.onboardingCompleted = false,
  });
}
