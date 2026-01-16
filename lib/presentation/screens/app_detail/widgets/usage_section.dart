import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/duration_extensions.dart';
import '../../../../domain/entities/app_limit.dart';

class UsageSection extends StatelessWidget {
  final AsyncValue<Duration> usageToday;
  final AsyncValue<AppLimit?> limit;

  const UsageSection({
    super.key,
    required this.usageToday,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.todayUsage,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          usageToday.when(
            data: (duration) => _buildUsageContent(context, duration),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error loading usage'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageContent(BuildContext context, Duration duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          duration.toReadableString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        limit.when(
          data: (appLimit) {
            if (appLimit == null) return const SizedBox.shrink();
            return _buildProgressIndicator(context, duration, appLimit);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    Duration duration,
    AppLimit appLimit,
  ) {
    final progress = appLimit.dailyLimit.inSeconds > 0
        ? duration.inSeconds / appLimit.dailyLimit.inSeconds
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Limit: ${appLimit.dailyLimit.toReadableString()}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            Text(
              progress > 1
                  ? '${(duration.inMinutes - appLimit.dailyLimit.inMinutes)} min over limit'
                  : '${(progress * 100).toInt()}% used',
              style: TextStyle(
                fontSize: 12,
                color: progress > 1 ? AppColors.error : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.getSurfaceVariant(context),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 1
                  ? AppColors.error
                  : progress > 0.8
                      ? AppColors.warning
                      : AppColors.success,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
