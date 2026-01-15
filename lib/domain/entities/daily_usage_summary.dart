import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_usage.dart';

part 'daily_usage_summary.freezed.dart';

@freezed
sealed class DailyUsageSummary with _$DailyUsageSummary {
  const factory DailyUsageSummary({
    required DateTime date,
    required Duration totalScreenTime,
    required List<AppUsage> appUsages,
    required int appsUsed,
  }) = _DailyUsageSummary;
}
