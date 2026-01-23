import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';

class ThemePicker extends ConsumerWidget {
  final int currentMode;

  const ThemePicker({
    super.key,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
          _ThemeOption(
            icon: Icons.brightness_auto,
            title: 'System',
            subtitle: 'Follow system settings',
            mode: 0,
            currentMode: currentMode,
            onTap: () {
              ref.read(settingsNotifierProvider.notifier).setThemeMode(0);
              Navigator.pop(context);
            },
          ),
          _ThemeOption(
            icon: Icons.light_mode,
            title: 'Light',
            subtitle: 'Always use light theme',
            mode: 1,
            currentMode: currentMode,
            onTap: () {
              ref.read(settingsNotifierProvider.notifier).setThemeMode(1);
              Navigator.pop(context);
            },
          ),
          _ThemeOption(
            icon: Icons.dark_mode,
            title: 'Dark',
            subtitle: 'Always use dark theme',
            mode: 2,
            currentMode: currentMode,
            onTap: () {
              ref.read(settingsNotifierProvider.notifier).setThemeMode(2);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int mode;
  final int currentMode;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.currentMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == currentMode;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isSelected ? AppColors.primary : AppColors.getTextSecondary(context))
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.getTextSecondary(context),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
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
      onTap: onTap,
    );
  }
}
