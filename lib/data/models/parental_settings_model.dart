import 'package:hive_ce/hive.dart';

part 'parental_settings_model.g.dart';

@HiveType(typeId: 1)
class ParentalSettingsModel extends HiveObject {
  @HiveField(0)
  bool isEnabled;

  @HiveField(1)
  String? pinHash;

  @HiveField(2)
  bool childModeEnabled;

  ParentalSettingsModel({
    this.isEnabled = false,
    this.pinHash,
    this.childModeEnabled = false,
  });
}
