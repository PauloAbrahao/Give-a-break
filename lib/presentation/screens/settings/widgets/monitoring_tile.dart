import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MonitoringTile extends StatelessWidget {
  final bool isRunning;
  final VoidCallback? onTap;

  const MonitoringTile({
    super.key,
    required this.isRunning,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isRunning ? AppColors.primary : AppColors.warning)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isRunning ? Icons.visibility : Icons.visibility_off,
          color: isRunning ? AppColors.primary : AppColors.warning,
        ),
      ),
      title: const Text('App Monitoring'),
      subtitle: Text(
        isRunning ? 'Active' : 'Inactive - tap to enable accessibility',
        style: TextStyle(
          color: isRunning ? AppColors.success : AppColors.warning,
        ),
      ),
      trailing: isRunning
          ? const Icon(Icons.check_circle, color: AppColors.success)
          : const Icon(Icons.chevron_right),
      onTap: !isRunning ? onTap : null,
    );
  }
}
