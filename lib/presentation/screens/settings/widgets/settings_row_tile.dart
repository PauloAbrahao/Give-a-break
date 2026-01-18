import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsRowTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData rightIcon;
  final VoidCallback onTap;

  const SettingsRowTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.rightIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.success),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.getTextSecondary(context),
        ),
      ),
      trailing: Icon(rightIcon),
      onTap: onTap,
    );
  }
}
