import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/permission_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/monitoring_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionProvider.notifier).checkAllPermissions();
      ref.read(monitoringProvider.notifier).checkServiceStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionProvider);
    final monitoring = ref.watch(monitoringProvider);
    // monitoringEnabledProvider used for persisting state across app restarts
    ref.watch(monitoringEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Monitoring Section
          _buildSectionHeader(AppStrings.monitoring),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (monitoring.isRunning
                              ? AppColors.success
                              : AppColors.textTertiary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      monitoring.isRunning
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: monitoring.isRunning
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                  ),
                  title: const Text('App Monitoring'),
                  subtitle: Text(
                    monitoring.isRunning ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: monitoring.isRunning
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                  ),
                  trailing: Switch(
                    value: monitoring.isRunning,
                    onChanged: (enabled) async {
                      if (enabled) {
                        await ref
                            .read(monitoringProvider.notifier)
                            .startMonitoring();
                        await ref
                            .read(settingsNotifierProvider.notifier)
                            .setMonitoringEnabled(true);
                      } else {
                        await ref
                            .read(monitoringProvider.notifier)
                            .stopMonitoring();
                        await ref
                            .read(settingsNotifierProvider.notifier)
                            .setMonitoringEnabled(false);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Permissions Section
          _buildSectionHeader(AppStrings.permissions),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildPermissionTile(
                  title: AppStrings.permissionUsageStatsTitle,
                  subtitle: AppStrings.permissionUsageStatsDesc,
                  icon: Icons.bar_chart,
                  isGranted: permissions.usageStatsGranted,
                  onTap: () {
                    ref
                        .read(permissionProvider.notifier)
                        .requestUsageStatsPermission();
                  },
                ),
                const Divider(height: 1),
                _buildPermissionTile(
                  title: AppStrings.permissionOverlayTitle,
                  subtitle: AppStrings.permissionOverlayDesc,
                  icon: Icons.layers,
                  isGranted: permissions.overlayGranted,
                  onTap: () {
                    ref
                        .read(permissionProvider.notifier)
                        .requestOverlayPermission();
                  },
                ),
                const Divider(height: 1),
                _buildPermissionTile(
                  title: AppStrings.permissionNotificationTitle,
                  subtitle: AppStrings.permissionNotificationDesc,
                  icon: Icons.notifications,
                  isGranted: permissions.notificationGranted,
                  onTap: () {
                    ref
                        .read(permissionProvider.notifier)
                        .requestNotificationPermission();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(AppStrings.about),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(AppStrings.appName),
                  subtitle: const Text('Version 1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isGranted ? AppColors.success : AppColors.primary)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isGranted ? AppColors.success : AppColors.primary,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: isGranted
          ? const Icon(Icons.check_circle, color: AppColors.success)
          : TextButton(
              onPressed: onTap,
              child: const Text('Grant'),
            ),
      onTap: isGranted ? null : onTap,
    );
  }
}
