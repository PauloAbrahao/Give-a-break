import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_a_break/presentation/screens/import_settings/import_settings.dart';
import 'package:give_a_break/presentation/screens/onboarding/onboarding_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/permission_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/monitoring_provider.dart';

import 'widgets/section_header.dart';
import 'widgets/monitoring_tile.dart';
import 'widgets/settings_row_tile.dart';
import 'widgets/permission_tile.dart';
import 'widgets/about_tile.dart';
import 'widgets/theme_picker.dart';

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
    final themeMode = ref.watch(themeModeProvider);
    // monitoringEnabledProvider used for persisting state across app restarts
    ref.watch(monitoringEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.settings,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Application Section
          const SectionHeader(title: AppStrings.application),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // App Monitoring
                MonitoringTile(
                  isRunning: monitoring.isRunning,
                  onTap: () async {
                    await ref
                        .read(monitoringProvider.notifier)
                        .startMonitoring();
                  },
                ),
                Divider(height: 1, color: AppColors.getDivider(context)),
                // Import
                SettingsRowTile(
                  title: AppStrings.import,
                  subtitle: AppStrings.importSubtitle,
                  icon: Icons.download,
                  rightIcon: Icons.chevron_right,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DataImportExportScreen(),
                    ),
                  ),
                ),
                Divider(height: 1, color: AppColors.getDivider(context)),
                // Theme
                SettingsRowTile(
                  title: AppStrings.theme,
                  subtitle: themeMode.when(
                    data: (mode) => _getThemeModeName(mode),
                    loading: () => 'Loading...',
                    error: (_, __) => 'System',
                  ),
                  icon: Icons.palette_outlined,
                  rightIcon: Icons.chevron_right,
                  onTap: () => _showThemePicker(context, themeMode.valueOrNull ?? 0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SectionHeader(title: AppStrings.help),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Help
                SettingsRowTile(
                  title: AppStrings.onboarding,
                  subtitle: 'Show the onboarding screens again',
                  icon: Icons.map_outlined,
                  rightIcon: Icons.chevron_right,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const OnboardingScreen(fromSettings: true),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Permissions Section
          const SectionHeader(title: AppStrings.permissions),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                PermissionTile(
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
                Divider(height: 1, color: AppColors.getDivider(context)),
                PermissionTile(
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
                Divider(height: 1, color: AppColors.getDivider(context)),
                PermissionTile(
                  title: AppStrings.permissionAccessibilityTitle,
                  subtitle: AppStrings.permissionAccessibilityDesc,
                  icon: Icons.accessibility_new,
                  isGranted: permissions.accessibilityGranted,
                  onTap: () {
                    ref
                        .read(permissionProvider.notifier)
                        .requestAccessibilityPermission();
                  },
                ),
                Divider(height: 1, color: AppColors.getDivider(context)),
                PermissionTile(
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
          const SectionHeader(title: AppStrings.about),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                AboutTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(int mode) {
    switch (mode) {
      case 1:
        return 'Light';
      case 2:
        return 'Dark';
      default:
        return 'System';
    }
  }

  void _showThemePicker(BuildContext context, int currentMode) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      backgroundColor: Colors.transparent,
      builder: (context) => ThemePicker(currentMode: currentMode),
    );
  }
}
