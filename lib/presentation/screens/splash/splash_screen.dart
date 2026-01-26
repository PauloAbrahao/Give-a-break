import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/method_channel_service.dart';
import '../../providers/permission_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/monitoring_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await ref.read(permissionProvider.notifier).checkAllPermissions();

    if (!mounted) return;

    // Check if onboarding is completed
    final onboardingCompleted =
        await ref.read(onboardingCompletedProvider.future);

    if (!mounted) return;

    final permissions = ref.read(permissionProvider);

    if (onboardingCompleted && permissions.coreGranted) {
      await ref.read(monitoringProvider.notifier).startMonitoring();

      await _waitForAccessibilityService();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  Future<void> _waitForAccessibilityService() async {
    final isEnabled = await MethodChannelService.checkAccessibilityPermission();
    if (!isEnabled) return;

    var isRunning = await MethodChannelService.isAccessibilityServiceRunning();
    if (isRunning) return;

    for (var i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      isRunning = await MethodChannelService.isAccessibilityServiceRunning();
      if (isRunning) return;
    }

    if (mounted) {
      await _showAccessibilityReconnectDialog();
    }
  }

  Future<void> _showAccessibilityReconnectDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Service Reconnection Required'),
          content: const Text(
            'The accessibility service needs to be reconnected. '
            'Please go to Settings and toggle the "Give a Break" accessibility service off and then on again.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                Navigator.of(context).pop();
                await MethodChannelService.requestAccessibilityPermission();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.timer_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.appTagline,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
