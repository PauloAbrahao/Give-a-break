import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_usage.freezed.dart';

@freezed
sealed class AppUsage with _$AppUsage {
  const factory AppUsage({
    required String packageName,
    required Duration totalTimeInForeground,
    required DateTime lastTimeUsed,
    required DateTime date,
    @Default(0) int openCount,
  }) = _AppUsage;
}
