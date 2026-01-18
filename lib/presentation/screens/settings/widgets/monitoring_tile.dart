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
          color: (isRunning ? AppColors.success : AppColors.warning)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isRunning ? Icons.visibility : Icons.visibility_off,
          color: isRunning ? AppColors.success : AppColors.warning,
        ),
      ),
      title: const Text('App Monitoring'),
      subtitle: Text(
        isRunning ? 'Active' : 'Starting...',
        style: TextStyle(
          color: isRunning ? AppColors.success : AppColors.warning,
        ),
      ),
      trailing: isRunning
          ? const Icon(Icons.check_circle, color: AppColors.success)
          : const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
      onTap: !isRunning ? onTap : null,
    );
  }
}
