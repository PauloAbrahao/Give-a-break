import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class DaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onChanged;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  static const List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _dayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  @override
  Widget build(BuildContext context) {
    final allSelected = selectedDays.length == 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Repeat',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (allSelected) {
                  onChanged({});
                } else {
                  onChanged({0, 1, 2, 3, 4, 5, 6});
                }
              },
              child: Text(
                allSelected ? 'Clear all' : 'Every day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isSelected = selectedDays.contains(index);
            return _DayButton(
              label: _dayLabels[index],
              tooltip: _dayNames[index],
              isSelected: isSelected,
              onTap: () {
                final newSet = Set<int>.from(selectedDays);
                if (isSelected) {
                  newSet.remove(index);
                } else {
                  newSet.add(index);
                }
                onChanged(newSet);
              },
            );
          }),
        ),
      ],
    );
  }
}

class _DayButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayButton({
    required this.label,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.getSurfaceVariant(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.getSurfaceVariant(context),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppColors.getTextSecondary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
