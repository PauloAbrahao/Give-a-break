import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class TimeLimitPicker extends StatefulWidget {
  final int initialHours;
  final int initialMinutes;

  const TimeLimitPicker({
    super.key,
    required this.initialHours,
    required this.initialMinutes,
  });

  @override
  State<TimeLimitPicker> createState() => _TimeLimitPickerState();
}

class _TimeLimitPickerState extends State<TimeLimitPicker> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late int _selectedHours;
  late int _selectedMinutes;

  static const int _maxHours = 12;
  static const int _maxMinutes = 59;

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.initialHours.clamp(0, _maxHours);
    _selectedMinutes = widget.initialMinutes.clamp(0, _maxMinutes);
    _hoursController = FixedExtentScrollController(initialItem: _selectedHours);
    _minutesController =
        FixedExtentScrollController(initialItem: _selectedMinutes);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildTitle(context),
          _buildPicker(context),
          const SizedBox(height: 20),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 36,
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        AppStrings.setAppLimits,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.getTextPrimary(context),
        ),
      ),
    );
  }

  Widget _buildPicker(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            _buildSelectionHighlight(),
            _buildWheelPickers(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionHighlight() {
    return Center(
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildWheelPickers(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: _hoursController,
            itemExtent: 44,
            physics: const FixedExtentScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            perspective: 0.003,
            diameterRatio: 1.5,
            useMagnifier: true,
            magnification: 1.1,
            overAndUnderCenterOpacity: 0.5,
            onSelectedItemChanged: (index) {
              setState(() => _selectedHours = index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _maxHours + 1,
              builder: (context, index) {
                return Center(
                  child: Text(
                    '$index ${index == 1 ? 'hour' : 'hours'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Text(
          ':',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextSecondary(context),
          ),
        ),
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: _minutesController,
            itemExtent: 44,
            physics: const FixedExtentScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            perspective: 0.003,
            diameterRatio: 1.5,
            useMagnifier: true,
            magnification: 1.1,
            overAndUnderCenterOpacity: 0.5,
            onSelectedItemChanged: (index) {
              setState(() => _selectedMinutes = index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _maxMinutes + 1,
              builder: (context, index) {
                return Center(
                  child: Text(
                    '$index ${index == 1 ? 'minute' : 'minutes'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedHours == 0 && _selectedMinutes == 0
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        Duration(
                          hours: _selectedHours,
                          minutes: _selectedMinutes,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.withOpacity(0.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppStrings.setLimit,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
