import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import 'overlay_color_option.dart';
import 'overlay_color_circle.dart';

class OverlayColorSelector extends StatelessWidget {
  final String? selectedColor;
  final ValueChanged<String?> onColorChanged;

  const OverlayColorSelector({
    super.key,
    this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = selectedColor ?? OverlayColorOption.defaultColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Button Color',
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: OverlayColorOption.options.map((option) {
            final isSelected = effectiveColor == option.color;
            return OverlayColorCircle(
              color: option.color,
              isSelected: isSelected,
              onTap: () => onColorChanged(option.color),
            );
          }).toList(),
        ),
      ],
    );
  }
}
