import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_a_break/presentation/providers/installed_apps_provider.dart';
import 'package:give_a_break/presentation/providers/routine_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/method_channel_service.dart';
import '../../providers/usage_provider.dart';
import '../../providers/monitoring_provider.dart';
import '../../providers/app_limit_provider.dart';
import '../../widgets/floating_menu.dart';
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

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  bool _needsReconnect = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check monitoring service status
    ref.read(monitoringProvider.notifier).checkServiceStatus();
    _checkAccessibilityStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(monitoringProvider.notifier).checkServiceStatus();
      _checkAccessibilityStatus();
    }
  }

  Future<void> _checkAccessibilityStatus() async {
    final needsReconnect = await MethodChannelService.needsAccessibilityReconnect();
    if (mounted && needsReconnect != _needsReconnect) {
      setState(() {
        _needsReconnect = needsReconnect;
      });
    }
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: const FloatingMenu(currentScreen: 'dashboard'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayUsageProvider);
          ref.invalidate(todaySummaryProvider);
          ref.invalidate(topAppsProvider);
          ref.invalidate(weeklySummaryProvider);
          ref.invalidate(allLimitsProvider);
          ref.invalidate(installedAppsProvider);
          ref.invalidate(routineRepositoryProvider);
          await _checkAccessibilityStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_needsReconnect) ...[
                _buildReconnectWarning(),
                const SizedBox(height: 16),
              ],
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

  Widget _buildReconnectWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Text(
                'Service Disconnected',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The app monitoring service needs to be reconnected. '
            'Please toggle the accessibility setting off and on again.',
            style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await MethodChannelService.requestAccessibilityPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Open Accessibility Settings'),
            ),
          ),
        ],
      ),
    );
  }
}
