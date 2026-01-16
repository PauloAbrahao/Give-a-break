import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/usage_provider.dart';
import '../../providers/monitoring_provider.dart';
import '../../providers/app_limit_provider.dart';
import '../app_list/app_list_screen.dart';
import '../app_detail/app_detail_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/usage_summary_card.dart';
import 'widgets/top_apps_list.dart';
import 'widgets/daily_chart.dart';
import 'widgets/restricted_apps_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Check monitoring service status
    ref.read(monitoringProvider.notifier).checkServiceStatus();
  }

  @override
  Widget build(BuildContext context) {
    final todaySummary = ref.watch(todaySummaryProvider);
    final topApps = ref.watch(topAppsProvider);
    final weeklySummary = ref.watch(weeklySummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: const Icon(Icons.apps),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todaySummaryProvider);
          ref.invalidate(topAppsProvider);
          ref.invalidate(weeklySummaryProvider);
          ref.invalidate(allLimitsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Today's Usage
                    Expanded(
                      child: todaySummary.when(
                        data: (summary) => UsageSummaryCard(
                          totalTime: summary.totalScreenTime,
                          appsUsed: summary.appsUsed,
                        ),
                        loading: () => const UsageSummaryCard(
                          totalTime: Duration.zero,
                          appsUsed: 0,
                          isLoading: true,
                        ),
                        error: (_, __) => const UsageSummaryCard(
                          totalTime: Duration.zero,
                          appsUsed: 0,
                          hasError: true,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Restricted Apps
                    Expanded(
                      child: RestrictedAppsCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AppListScreen(initialTabIndex: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Top Apps
              _buildSectionHeader(
                title: AppStrings.mostUsedApps,
              ),
              const SizedBox(height: 12),
              topApps.when(
                data: (apps) => TopAppsList(
                  apps: apps,
                  onAppTap: (packageName) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AppDetailScreen(packageName: packageName),
                      ),
                    );
                  },
                ),
                loading: () => const TopAppsList(apps: [], isLoading: true),
                error: (_, __) => const Center(
                  child: Text(AppStrings.noUsageData),
                ),
              ),
              const SizedBox(height: 24),

              // Weekly Chart
              _buildSectionHeader(title: AppStrings.weeklyOverview),
              const SizedBox(height: 12),
              weeklySummary.when(
                data: (summaries) => DailyChart(summaries: summaries),
                loading: () => const DailyChart(summaries: [], isLoading: true),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

}
