import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class DaysDisplay extends StatelessWidget {
  final Set<int> selectedDays;
  final double size;

  const DaysDisplay({
    super.key,
    required this.selectedDays,
    this.size = 22,
  });

  static const List<String> dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (index) {
        final isSelected = selectedDays.contains(index);
        return Container(
          width: size,
          height: size,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.getSurfaceVariant(context),
            borderRadius: BorderRadius.circular(size / 2),
          ),
          child: Center(
            child: Text(
              dayLabels[index],
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextSecondary(context),
              ),
            ),
          ),
        );
      }),
    );
  }
}
