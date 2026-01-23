import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import 'overlay_color_option.dart';
import 'overlay_icon_option.dart';
import 'overlay_icon_circle.dart';

class OverlayIconSelector extends StatelessWidget {
  final String? selectedIcon;
  final String? selectedColor;
  final ValueChanged<String?> onIconChanged;

  const OverlayIconSelector({
    super.key,
    this.selectedIcon,
    this.selectedColor,
    required this.onIconChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = selectedIcon ?? OverlayIconOption.defaultIcon;
    final effectiveColor = selectedColor ?? OverlayColorOption.defaultColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon',
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
          children: OverlayIconOption.options.map((option) {
            final isSelected = effectiveIcon == option.icon;
            return OverlayIconCircle(
              option: option,
              isSelected: isSelected,
              selectedColor: effectiveColor,
              onTap: () => onIconChanged(option.icon),
            );
          }).toList(),
        ),
      ],
    );
  }
}
