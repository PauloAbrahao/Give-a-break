import 'package:hive_ce/hive.dart';
import '../../domain/entities/app_limit.dart';

part 'app_limit_model.g.dart';

@HiveType(typeId: 0)
class AppLimitModel extends HiveObject {
  @HiveField(0)
  String packageName;

  @HiveField(1)
  int dailyLimitMinutes;

  @HiveField(3)
  int dailyLimitOpenings;

  @HiveField(4)
  bool isEnabled;

  AppLimitModel({
    required this.packageName,
    required this.dailyLimitMinutes,
    this.dailyLimitOpenings = 0,
    this.isEnabled = true,
  });

  factory AppLimitModel.fromEntity(AppLimit entity) {
    return AppLimitModel(
      packageName: entity.packageName,
      dailyLimitMinutes: entity.dailyLimit.inMinutes,
      dailyLimitOpenings: entity.dailyLimitOpenings,
      isEnabled: entity.isEnabled,
    );
  }

  AppLimit toEntity() {
    return AppLimit(
      packageName: packageName,
      dailyLimit: Duration(minutes: dailyLimitMinutes),
      dailyLimitOpenings: dailyLimitOpenings,
      isEnabled: isEnabled,
    );
  }
}
