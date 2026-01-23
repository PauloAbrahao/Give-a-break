import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import 'overlay_color_selector.dart';
import 'overlay_icon_selector.dart';

export 'overlay_color_option.dart';
export 'overlay_icon_option.dart';

class OverlaySettingsSelector extends StatelessWidget {
  final String? selectedColor;
  final String? selectedIcon;
  final ValueChanged<String?> onColorChanged;
  final ValueChanged<String?> onIconChanged;

  const OverlaySettingsSelector({
    super.key,
    this.selectedColor,
    this.selectedIcon,
    required this.onColorChanged,
    required this.onIconChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context),
        const SizedBox(height: 16),
        OverlayColorSelector(
          selectedColor: selectedColor,
          onColorChanged: onColorChanged,
        ),
        const SizedBox(height: 20),
        OverlayIconSelector(
          selectedIcon: selectedIcon,
          selectedColor: selectedColor,
          onIconChanged: onIconChanged,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.palette_outlined,
          size: 18,
          color: AppColors.getTextSecondary(context),
        ),
        const SizedBox(width: 8),
        Text(
          'Overlay Appearance',
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
