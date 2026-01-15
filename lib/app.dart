import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/extensions/duration_extensions.dart';
import 'core/services/overlay_service.dart';
import 'presentation/providers/monitoring_provider.dart';
import 'presentation/providers/installed_apps_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

class GiveABreakApp extends ConsumerWidget {
  const GiveABreakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to overlay trigger and show overlay when needed
    ref.listen<OverlayTriggerState>(overlayTriggerProvider, (previous, next) async {
      if (next.shouldShow && next.packageName != null) {
        // Get app name from package name
        final appInfo = await ref.read(appInfoProvider(next.packageName!).future);
        final appName = appInfo?.appName ?? next.packageName!.split('.').last;

        // Show the system overlay
        await OverlayService.showOverlay(
          appName: appName,
          usedTime: next.usedTime?.toReadableString() ?? '--',
          limitTime: next.limitTime?.toReadableString() ?? '--',
        );

        // Reset the trigger state
        ref.read(overlayTriggerProvider.notifier).dismissOverlay();
      }
    });

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppColors.primary),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
