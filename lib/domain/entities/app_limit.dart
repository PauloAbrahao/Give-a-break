import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_limit.freezed.dart';

@freezed
sealed class AppLimit with _$AppLimit {
  const factory AppLimit({
    required String packageName,
    required Duration dailyLimit,
    @Default(0) int dailyLimitOpenings,
    @Default(true) bool isEnabled,
  }) = _AppLimit;
}
