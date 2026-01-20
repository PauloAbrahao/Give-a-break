import '../../core/services/method_channel_service.dart';
import '../../domain/entities/app_usage.dart';
import '../../domain/entities/daily_usage_summary.dart';

class UsageRepository {
  Future<List<AppUsage>> getUsageStats({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final stats = await MethodChannelService.getUsageStats(
      startTime: startTime.millisecondsSinceEpoch,
      endTime: endTime.millisecondsSinceEpoch,
    );

    return stats.map((stat) {
      return AppUsage(
        packageName: stat['packageName'] as String,
        totalTimeInForeground:
            Duration(milliseconds: stat['totalTimeInForeground'] as int),
        lastTimeUsed:
            DateTime.fromMillisecondsSinceEpoch(stat['lastTimeUsed'] as int),
        date: DateTime.fromMillisecondsSinceEpoch(stat['firstTimeStamp'] as int),
        openCount: stat['openCount'] as int? ?? 0,
      );
    }).toList();
  }

  Future<List<AppUsage>> getTodayUsage() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getUsageStats(startTime: startOfDay, endTime: now);
  }

  Future<Duration> getAppUsageToday(String packageName) async {
    final todayUsage = await getTodayUsage();
    final appUsage = todayUsage.where((u) => u.packageName == packageName);
    if (appUsage.isEmpty) {
      return Duration.zero;
    }
    return appUsage.first.totalTimeInForeground;
  }

  Future<DailyUsageSummary> getDailySummary(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final usages = await getUsageStats(startTime: startOfDay, endTime: endOfDay);

    final totalTime = usages.fold<Duration>(
      Duration.zero,
      (total, usage) => total + usage.totalTimeInForeground,
    );

    return DailyUsageSummary(
      date: date,
      totalScreenTime: totalTime,
      appUsages: usages,
      appsUsed: usages.length,
    );
  }

  Future<List<DailyUsageSummary>> getWeeklySummary() async {
    final summaries = <DailyUsageSummary>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final summary = await getDailySummary(date);
      summaries.add(summary);
    }

    return summaries;
  }

  Future<List<AppUsage>> getTopApps({int limit = 5}) async {
    final todayUsage = await getTodayUsage();
    todayUsage.sort(
      (a, b) =>
          b.totalTimeInForeground.compareTo(a.totalTimeInForeground),
    );
    return todayUsage.take(limit).toList();
  }
}
