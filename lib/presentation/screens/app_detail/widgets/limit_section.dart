import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/duration_extensions.dart';
import '../../../../domain/entities/app_limit.dart';

class LimitSection extends StatelessWidget {
  final AsyncValue<AppLimit?> limit;
  final void Function(bool enabled) onToggleLimit;
  final VoidCallback onEditLimit;
  final void Function(AppLimit limit) onEditDailyOpenings;
  final void Function(AppLimit limit) onEditWarning;
  final VoidCallback onRemoveLimit;
  final VoidCallback onSetLimit;

  const LimitSection({
    super.key,
    required this.limit,
    required this.onToggleLimit,
    required this.onEditLimit,
    required this.onEditDailyOpenings,
    required this.onEditWarning,
    required this.onRemoveLimit,
    required this.onSetLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              limit.when(
                data: (appLimit) {
                  if (appLimit != null) {
                    return Switch(
                      value: appLimit.isEnabled,
                      onChanged: onToggleLimit,
                      activeThumbColor: AppColors.success,
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          limit.when(
            data: (appLimit) {
              if (appLimit != null) {
                return _buildLimitDetails(context, appLimit);
              }
              return _buildNoLimitState(context);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error loading limit'),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitDetails(BuildContext context, AppLimit appLimit) {
    return Column(
      children: [
        _buildLimitRow(
          context,
          'Daily limit',
          appLimit.dailyLimit.inSeconds == 0
              ? 'Disabled'
              : appLimit.dailyLimit.toReadableString(),
          onEditLimit,
        ),
        const SizedBox(height: 6),
        _buildLimitRow(
          context,
          'Warning at',
          '${(appLimit.warningThreshold * 100).toInt()}%',
          () => onEditWarning(appLimit),
        ),
        const SizedBox(height: 6),
        _buildLimitRow(
          context,
          'Daily Opens',
          appLimit.dailyLimitOpenings == 0
              ? 'Disabled'
              : appLimit.dailyLimitOpenings.toString(),
          () => onEditDailyOpenings(appLimit),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onRemoveLimit,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            label: const Text(
              AppStrings.removeLimit,
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoLimitState(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.noLimitSet,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSetLimit,
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.setLimit),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitRow(
    BuildContext context,
    String label,
    String value,
    VoidCallback? onEdit,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(context),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceVariant(context).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
