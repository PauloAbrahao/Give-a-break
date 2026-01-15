import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_limit.freezed.dart';

@freezed
sealed class AppLimit with _$AppLimit {
  const factory AppLimit({
    required String packageName,
    required Duration dailyLimit,
    @Default(0.8) double warningThreshold,
    @Default(Duration(minutes: 5)) Duration cooldownPeriod,
    @Default(true) bool isEnabled,
    DateTime? lastWarningShown,
  }) = _AppLimit;
}
