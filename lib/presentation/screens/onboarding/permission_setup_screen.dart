import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/permission_provider.dart';
import '../../providers/settings_provider.dart';
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
  Completer<void>? _returnFromSettingsCompleter;
  bool _hasLeftApp = false;
  bool _isGrantingAll = false;

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
    if (state == AppLifecycleState.paused) {
      _hasLeftApp = true;
      return;
    }

    if (state != AppLifecycleState.resumed) return;

    ref.read(permissionProvider.notifier).checkAllPermissions();

    if (!_hasLeftApp) return;
    _hasLeftApp = false;
    _returnFromSettingsCompleter?.complete();
    _returnFromSettingsCompleter = null;
  }

  Future<void> _grantAllPermissions() async {
    setState(() => _isGrantingAll = true);
    final notifier = ref.read(permissionProvider.notifier);

    await notifier.checkAllPermissions();

    if (!ref.read(permissionProvider).usageStatsGranted) {
      await _openSettingsAndWaitForReturn(notifier.requestUsageStatsPermission);
    }

    if (mounted && !ref.read(permissionProvider).accessibilityGranted) {
      await _openSettingsAndWaitForReturn(
        notifier.requestAccessibilityPermission,
      );
    }

    if (!mounted) return;
    setState(() => _isGrantingAll = false);
  }

  Future<void> _openSettingsAndWaitForReturn(
    Future<void> Function() openSettings,
  ) async {
    final completer = Completer<void>();
    _returnFromSettingsCompleter = completer;
    _hasLeftApp = false;

    await openSettings();
    await completer.future;
    await ref.read(permissionProvider.notifier).checkAllPermissions();
  }

  Future<void> _completeSetup() async {
    await ref
        .read(settingsNotifierProvider.notifier)
        .setOnboardingCompleted(true);

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
            const SizedBox(height: 24),
            if (!permissions.coreGranted) ...[
              OutlinedButton.icon(
                onPressed: _isGrantingAll ? null : _grantAllPermissions,
                icon: const Icon(Icons.done_all),
                label: const Text(AppStrings.grantAllPermissions),
              ),
              const SizedBox(height: 24),
            ],
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
              title: AppStrings.permissionAccessibilityTitle,
              description: AppStrings.permissionAccessibilityDesc,
              icon: Icons.accessibility_new,
              isGranted: permissions.accessibilityGranted,
              onRequest: () {
                ref
                    .read(permissionProvider.notifier)
                    .requestAccessibilityPermission();
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
                AppStrings.corePermissionsRequired,
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
