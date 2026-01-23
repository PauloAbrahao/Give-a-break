import 'package:flutter/material.dart';
import 'package:give_a_break/core/constants/app_colors.dart';

class OverlayColorCircle extends StatelessWidget {
  final String color;
  final bool isSelected;
  final VoidCallback onTap;

  const OverlayColorCircle({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorValue = _parseColor(color);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorValue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.getBackground(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Color _parseColor(String hex) {
    final hexColor = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
