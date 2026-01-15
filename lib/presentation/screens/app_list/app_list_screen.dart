import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../domain/entities/app_info.dart';
import '../../../domain/entities/app_usage.dart';
import '../../providers/installed_apps_provider.dart';
import '../../providers/usage_provider.dart';
import '../../providers/app_limit_provider.dart';
import '../app_detail/app_detail_screen.dart';

class AppListScreen extends ConsumerStatefulWidget {
  const AppListScreen({super.key});

  @override
  ConsumerState<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends ConsumerState<AppListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.allAppsTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.allApps),
            Tab(text: AppStrings.appsWithLimits),
          ],
          dividerColor: AppColors.dividerBackground,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppStrings.searchApps,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllAppsList(),
                _buildAppsWithLimitsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllAppsList() {
    final installedApps = ref.watch(installedAppsProvider);
    final todayUsage = ref.watch(todayUsageProvider);

    return installedApps.when(
      data: (apps) {
        final filteredApps = apps.where((app) {
          if (_searchQuery.isEmpty) return true;
          return app.appName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: filteredApps.length,
          itemBuilder: (context, index) {
            final app = filteredApps[index];
            return _buildAppTile(app, todayUsage);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading apps')),
    );
  }

  Widget _buildAppsWithLimitsList() {
    final limits = ref.watch(allLimitsProvider);
    final installedApps = ref.watch(installedAppsProvider);
    final todayUsage = ref.watch(todayUsageProvider);

    return limits.when(
      data: (limitList) {
        if (limitList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_off,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                SizedBox(height: 16),
                Text(
                  'No app limits set yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap on any app to set a daily limit',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return installedApps.when(
          data: (apps) {
            final limitedApps = apps.where((app) {
              return limitList
                  .any((limit) => limit.packageName == app.packageName);
            }).where((app) {
              if (_searchQuery.isEmpty) return true;
              return app.appName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView.builder(
              itemCount: limitedApps.length,
              itemBuilder: (context, index) {
                final app = limitedApps[index];
                final limit = limitList.firstWhere(
                  (l) => l.packageName == app.packageName,
                );
                return _buildAppTile(app, todayUsage, limit: limit);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading apps')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading limits')),
    );
  }

  Widget _buildAppTile(
    AppInfo app,
    AsyncValue<List<AppUsage>> todayUsage, {
    dynamic limit,
  }) {
    return ListTile(
      leading: _buildAppIcon(app.icon),
      title: Text(
        app.appName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: todayUsage.when(
        data: (usages) {
          final matchingUsages = usages.where(
            (u) => u.packageName == app.packageName,
          );
          if (matchingUsages.isNotEmpty) {
            final usage = matchingUsages.first;
            final duration = usage.totalTimeInForeground;
            return Text(
              'Used ${duration.toReadableString()} today',
              style: const TextStyle(fontSize: 12),
            );
          }
          return const Text(
            'Not used today',
            style: TextStyle(fontSize: 12),
          );
        },
        loading: () => const Text('...'),
        error: (_, __) => const Text('...'),
      ),
      trailing: limit != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (limit.dailyLimit as Duration).toReadableString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AppDetailScreen(packageName: app.packageName),
          ),
        );
      },
    );
  }

  Widget _buildAppIcon(dynamic icon) {
    if (icon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          icon,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.android,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}
