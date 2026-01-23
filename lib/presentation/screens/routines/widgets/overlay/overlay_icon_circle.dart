import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constants/app_colors.dart';
import 'overlay_icon_option.dart';

class OverlayIconCircle extends StatelessWidget {
  final OverlayIconOption option;
  final bool isSelected;
  final String selectedColor;
  final VoidCallback onTap;

  const OverlayIconCircle({
    super.key,
    required this.option,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _parseColor(selectedColor);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withAlpha(50)
              : AppColors.getSurfaceVariant(context),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: accentColor, width: 2)
              : Border.all(color: AppColors.getDivider(context), width: 1),
        ),
        child: Center(
          child: SvgPicture.asset(
            option.asset,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isSelected ? accentColor : AppColors.getTextSecondary(context),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final hexColor = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
