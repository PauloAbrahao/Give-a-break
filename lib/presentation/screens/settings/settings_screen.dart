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
          // Monitoring Section
          _buildSectionHeader(context, AppStrings.monitoring),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      (monitoring.isRunning
                              ? AppColors.success
                              : AppColors.warning)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  monitoring.isRunning
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: monitoring.isRunning
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              title: const Text('App Monitoring'),
              subtitle: Text(
                monitoring.isRunning ? 'Active' : 'Starting...',
                style: TextStyle(
                  color: monitoring.isRunning
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              trailing: monitoring.isRunning
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
              onTap: !monitoring.isRunning
                  ? () async {
                      await ref
                          .read(monitoringProvider.notifier)
                          .startMonitoring();
                    }
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  color: AppColors.success,
                ),
              ),
              title: const Text('Theme'),
              subtitle: Text(
                themeMode.when(
                  data: (mode) => _getThemeModeName(mode),
                  loading: () => 'Loading...',
                  error: (_, __) => 'System',
                ),
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemePicker(context, themeMode.valueOrNull ?? 0),
            ),
          ),
          const SizedBox(height: 24),

          // Permissions Section
          _buildSectionHeader(context, AppStrings.permissions),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildPermissionTile(
                  context: context,
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
                _buildPermissionTile(
                  context: context,
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
                _buildPermissionTile(
                  context: context,
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
          _buildSectionHeader(context, AppStrings.about),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.success,
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextSecondary(context),
      ),
    );
  }

  Widget _buildPermissionTile({
    required BuildContext context,
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
        style: TextStyle(
          fontSize: 12,
          color: AppColors.getTextSecondary(context),
        ),
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildThemeOption(
              context: context,
              icon: Icons.brightness_auto,
              title: 'System',
              subtitle: 'Follow system settings',
              mode: 0,
              currentMode: currentMode,
            ),
            _buildThemeOption(
              context: context,
              icon: Icons.light_mode,
              title: 'Light',
              subtitle: 'Always use light theme',
              mode: 1,
              currentMode: currentMode,
            ),
            _buildThemeOption(
              context: context,
              icon: Icons.dark_mode,
              title: 'Dark',
              subtitle: 'Always use dark theme',
              mode: 2,
              currentMode: currentMode,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required int mode,
    required int currentMode,
  }) {
    final isSelected = mode == currentMode;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isSelected ? AppColors.success : AppColors.getTextSecondary(context))
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.success : AppColors.getTextSecondary(context),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.success : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.getTextSecondary(context),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.success)
          : null,
      onTap: () {
        ref.read(settingsNotifierProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
