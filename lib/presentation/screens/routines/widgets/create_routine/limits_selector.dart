import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/extensions/duration_extensions.dart';
import '../../../app_detail/widgets/time_limit_picker.dart';
import '../../../app_detail/widgets/daily_openings_picker.dart';

class LimitsSelector extends StatelessWidget {
  final Duration dailyLimit;
  final int dailyLimitOpenings;
  final ValueChanged<Duration> onDailyLimitChanged;
  final ValueChanged<int> onDailyOpeningsChanged;

  const LimitsSelector({
    super.key,
    required this.dailyLimit,
    required this.dailyLimitOpenings,
    required this.onDailyLimitChanged,
    required this.onDailyOpeningsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Limits',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LimitButton(
                label: 'Daily Limit',
                value: dailyLimit.inSeconds == 0
                    ? 'Disabled'
                    : dailyLimit.toReadableString(),
                onTap: () => _showDailyLimitPicker(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _LimitButton(
                label: 'Daily Opens',
                value: dailyLimitOpenings == 0
                    ? 'Disabled'
                    : dailyLimitOpenings.toString(),
                onTap: () => _showDailyOpeningsPicker(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showDailyLimitPicker(BuildContext context) async {
    final result = await showModalBottomSheet<Duration>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TimeLimitPicker(
        initialHours: dailyLimit.inHours,
        initialMinutes: dailyLimit.inMinutes.remainder(60),
      ),
    );

    if (result != null) {
      onDailyLimitChanged(result);
    }
  }

  Future<void> _showDailyOpeningsPicker(BuildContext context) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DailyOpeningsPicker(
        initialValue: dailyLimitOpenings,
      ),
    );

    if (result != null) {
      onDailyOpeningsChanged(result);
    }
  }
}

class _LimitButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _LimitButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.getTextSecondary(context).withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
