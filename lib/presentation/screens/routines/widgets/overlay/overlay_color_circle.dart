import 'package:flutter/material.dart';

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
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final hexColor = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
