import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RoutineDialogHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;

  const RoutineDialogHeader({
    super.key,
    required this.isEditing,
    this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEditing ? 'Edit Routine' : 'New Routine',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          if (isEditing)
            Row(
              children: [
                _ActionButton(
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  onPressed: onDelete,
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.archive_outlined,
                  color: AppColors.getTextSecondary(context),
                  onPressed: onArchive,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: color),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
        ),
      ),
    );
  }
}
