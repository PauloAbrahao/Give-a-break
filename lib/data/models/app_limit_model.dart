import 'package:hive_ce/hive.dart';
import '../../domain/entities/app_limit.dart';

part 'app_limit_model.g.dart';

@HiveType(typeId: 0)
class AppLimitModel extends HiveObject {
  @HiveField(0)
  String packageName;

  @HiveField(1)
  int dailyLimitMinutes;

  @HiveField(2)
  double warningThreshold;

  @HiveField(3)
  int cooldownMinutes;

  @HiveField(4)
  bool isEnabled;

  @HiveField(5)
  DateTime? lastWarningShown;

  AppLimitModel({
    required this.packageName,
    required this.dailyLimitMinutes,
    this.warningThreshold = 0.8,
    this.cooldownMinutes = 5,
    this.isEnabled = true,
    this.lastWarningShown,
  });

  factory AppLimitModel.fromEntity(AppLimit entity) {
    return AppLimitModel(
      packageName: entity.packageName,
      dailyLimitMinutes: entity.dailyLimit.inMinutes,
      warningThreshold: entity.warningThreshold,
      cooldownMinutes: entity.cooldownPeriod.inMinutes,
      isEnabled: entity.isEnabled,
      lastWarningShown: entity.lastWarningShown,
    );
  }

  AppLimit toEntity() {
    return AppLimit(
      packageName: packageName,
      dailyLimit: Duration(minutes: dailyLimitMinutes),
      warningThreshold: warningThreshold,
      cooldownPeriod: Duration(minutes: cooldownMinutes),
      isEnabled: isEnabled,
      lastWarningShown: lastWarningShown,
    );
  }
}
