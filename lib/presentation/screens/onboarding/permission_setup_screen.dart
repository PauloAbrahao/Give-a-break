import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/permission_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/monitoring_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'widgets/permission_card.dart';

class PermissionSetupScreen extends ConsumerStatefulWidget {
  final bool fromSettings;

  const PermissionSetupScreen({super.key, this.fromSettings = false});

  @override
  ConsumerState<PermissionSetupScreen> createState() =>
      _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends ConsumerState<PermissionSetupScreen>
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
    }
  }

  Future<void> _completeSetup() async {
    await ref
        .read(settingsNotifierProvider.notifier)
        .setOnboardingCompleted(true);

    // Start monitoring automatically
    await ref.read(monitoringProvider.notifier).startMonitoring();

    if (!mounted) return;

    // Go to Dashboard and clear the navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  void _goBackToSettings() {
    Navigator.of(context)
      ..pop()
      ..pop();
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.onboardingPermissionTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.onboardingPermissionSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            const SizedBox(height: 32),
            PermissionCard(
              title: AppStrings.permissionUsageStatsTitle,
              description: AppStrings.permissionUsageStatsDesc,
              icon: Icons.bar_chart,
              isGranted: permissions.usageStatsGranted,
              onRequest: () {
                ref
                    .read(permissionProvider.notifier)
                    .requestUsageStatsPermission();
              },
            ),
            const SizedBox(height: 16),
            PermissionCard(
              title: AppStrings.permissionOverlayTitle,
              description: AppStrings.permissionOverlayDesc,
              icon: Icons.layers,
              isGranted: permissions.overlayGranted,
              onRequest: () {
                ref
                    .read(permissionProvider.notifier)
                    .requestOverlayPermission();
              },
            ),
            const SizedBox(height: 16),
            PermissionCard(
              title: AppStrings.permissionNotificationTitle,
              description: AppStrings.permissionNotificationDesc,
              icon: Icons.notifications,
              isGranted: permissions.notificationGranted,
              onRequest: () {
                ref
                    .read(permissionProvider.notifier)
                    .requestNotificationPermission();
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: widget.fromSettings
                  ? _goBackToSettings
                  : (permissions.coreGranted ? _completeSetup : null),
              child: Text(widget.fromSettings ? 'Back' : AppStrings.done),
            ),
            const SizedBox(height: 8),
            if (!permissions.coreGranted)
              Text(
                'Please grant Usage Access and Overlay permissions to continue',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextTertiary(context),
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
