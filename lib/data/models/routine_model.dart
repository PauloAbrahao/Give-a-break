import 'package:hive_ce/hive.dart';
import '../../domain/entities/routine.dart';

part 'routine_model.g.dart';

@HiveType(typeId: 3)
class RoutineModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<int> days;

  @HiveField(4)
  List<String> appPackages;

  @HiveField(5)
  bool isEnabled;

  @HiveField(6)
  DateTime? createdAt;

  @HiveField(7)
  bool isArchived;

  @HiveField(8)
  String? startTime;

  @HiveField(9)
  String? endTime;

  @HiveField(10)
  int dailyLimitMinutes;

  @HiveField(11)
  int dailyLimitOpenings;

  @HiveField(12)
  String? overlayColor;

  @HiveField(13)
  String? overlayIcon;

  RoutineModel({
    required this.id,
    required this.name,
    this.description,
    required this.days,
    required this.appPackages,
    this.isEnabled = true,
    this.isArchived = false,
    this.createdAt,
    this.startTime,
    this.endTime,
    this.dailyLimitMinutes = 0,
    this.dailyLimitOpenings = 0,
    this.overlayColor,
    this.overlayIcon,
  });

  factory RoutineModel.fromEntity(Routine entity) {
    return RoutineModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      days: entity.days.toList(),
      appPackages: entity.appPackages.toList(),
      isEnabled: entity.isEnabled,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      startTime: entity.startTime,
      endTime: entity.endTime,
      dailyLimitMinutes: entity.dailyLimit.inMinutes,
      dailyLimitOpenings: entity.dailyLimitOpenings,
      overlayColor: entity.overlayColor,
      overlayIcon: entity.overlayIcon,
    );
  }

  Routine toEntity() {
    return Routine(
      id: id,
      name: name,
      description: description,
      days: days.toSet(),
      appPackages: appPackages.toSet(),
      isEnabled: isEnabled,
      isArchived: isArchived,
      createdAt: createdAt,
      startTime: startTime,
      endTime: endTime,
      dailyLimit: Duration(minutes: dailyLimitMinutes),
      dailyLimitOpenings: dailyLimitOpenings,
      overlayColor: overlayColor,
      overlayIcon: overlayIcon,
    );
  }
}
