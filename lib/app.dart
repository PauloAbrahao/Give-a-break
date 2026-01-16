import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/extensions/duration_extensions.dart';
import 'core/services/overlay_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/monitoring_provider.dart';
import 'presentation/providers/installed_apps_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

class GiveABreakApp extends ConsumerWidget {
  const GiveABreakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeModeAsync.when(
        data: (mode) => AppTheme.getThemeMode(mode),
        loading: () => ThemeMode.system,
        error: (_, __) => ThemeMode.system,
      ),
      home: const SplashScreen(),
    );
  }
}
