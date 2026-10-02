import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

class GiveABreakApp extends ConsumerWidget {
  const GiveABreakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);

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
