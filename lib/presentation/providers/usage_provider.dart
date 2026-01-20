import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/entities/app_usage.dart';
import '../../domain/entities/daily_usage_summary.dart';
import 'installed_apps_provider.dart';

final usageRepositoryProvider = Provider<UsageRepository>((ref) {
  return UsageRepository();
});

/// Provider that returns today's usage for user-installed apps only
final todayUsageProvider = FutureProvider<List<AppUsage>>((ref) async {
  final repo = ref.watch(usageRepositoryProvider);
  final allUsage = await repo.getTodayUsage();

  // Get user-installed apps to filter
  final installedApps = await ref.watch(installedAppsProvider.future);
  final userPackages = installedApps.map((app) => app.packageName).toSet();

  // Filter usage to only include user-installed apps
  return allUsage
      .where((usage) => userPackages.contains(usage.packageName))
      .toList();
});

/// Provider that returns only user-installed apps usage (excludes system apps)
final topAppsProvider = FutureProvider<List<AppUsage>>((ref) async {
  final repo = ref.watch(usageRepositoryProvider);
  final allUsage = await repo.getTopApps(limit: 50);

  // Get user-installed apps to filter
  final installedApps = await ref.watch(installedAppsProvider.future);
  final userPackages = installedApps.map((app) => app.packageName).toSet();

  // Filter usage to only include user-installed apps
  final userAppsUsage = allUsage
      .where((usage) => userPackages.contains(usage.packageName))
      .take(5)
      .toList();

  return userAppsUsage;
});

final todaySummaryProvider = FutureProvider<DailyUsageSummary>((ref) async {
  final repo = ref.watch(usageRepositoryProvider);
  return repo.getDailySummary(DateTime.now());
});

final weeklySummaryProvider =
    FutureProvider<List<DailyUsageSummary>>((ref) async {
  final repo = ref.watch(usageRepositoryProvider);
  return repo.getWeeklySummary();
});

final appUsageTodayProvider =
    FutureProvider.family<Duration, String>((ref, packageName) async {
  final repo = ref.watch(usageRepositoryProvider);
  return repo.getAppUsageToday(packageName);
});

final appUsageFullTodayProvider =
    FutureProvider.family<AppUsage?, String>((ref, packageName) async {
  final todayUsage = await ref.watch(todayUsageProvider.future);
  return todayUsage.where((u) => u.packageName == packageName).firstOrNull;
});
