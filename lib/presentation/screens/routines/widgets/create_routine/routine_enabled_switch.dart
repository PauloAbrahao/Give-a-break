import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class RoutineEnabledSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RoutineEnabledSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Enable routine',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}
