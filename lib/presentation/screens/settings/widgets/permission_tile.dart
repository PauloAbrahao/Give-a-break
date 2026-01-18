import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PermissionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isGranted;
  final VoidCallback onTap;

  const PermissionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          : TextButton(onPressed: onTap, child: const Text('Grant')),
      onTap: isGranted ? null : onTap,
    );
  }
}
