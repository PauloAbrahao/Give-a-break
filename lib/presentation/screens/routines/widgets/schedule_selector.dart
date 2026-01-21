import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ScheduleSelector extends StatelessWidget {
  final bool isAllDay;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<bool> onAllDayChanged;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;

  const ScheduleSelector({
    super.key,
    required this.isAllDay,
    required this.startTime,
    required this.endTime,
    required this.onAllDayChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        _buildTimePickers(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Schedule',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          'All Day',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(context),
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: isAllDay,
          onChanged: onAllDayChanged,
          activeThumbColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildTimePickers(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: !isAllDay
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _TimePicker(
                      label: 'Start',
                      time: startTime,
                      onChanged: onStartTimeChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TimePicker(
                      label: 'End',
                      time: endTime,
                      onChanged: onEndTimeChanged,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  const _TimePicker({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.getTextSecondary(context).withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              time.format(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
