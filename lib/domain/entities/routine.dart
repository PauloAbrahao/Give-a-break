import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine.freezed.dart';

@freezed
sealed class Routine with _$Routine {
  const factory Routine({
    required String id,
    required String name,
    String? description,
    required Set<int> days,
    required Set<String> appPackages,
    @Default(true) bool isEnabled,
    @Default(false) bool isArchived,
    DateTime? createdAt,
    String? startTime,
    String? endTime,
    @Default(Duration.zero) Duration dailyLimit,
    @Default(0) int dailyLimitOpenings,
    // Advanced overlay settings
    String? overlayColor, // Hex color like "#6366F1"
    String? overlayIcon, // Emoji icon like "⏰"
  }) = _Routine;
}
