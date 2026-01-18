import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WarningThresholdPicker extends StatefulWidget {
  final int initialPercentage;

  const WarningThresholdPicker({
    super.key,
    required this.initialPercentage,
  });

  @override
  State<WarningThresholdPicker> createState() => _WarningThresholdPickerState();
}

class _WarningThresholdPickerState extends State<WarningThresholdPicker> {
  late FixedExtentScrollController _percentageController;
  late int _selectedPercentage;

  static const List<int> _percentages = [50, 55, 60, 65, 70, 75, 80, 85, 90, 95];

  @override
  void initState() {
    super.initState();
    _selectedPercentage = widget.initialPercentage;
    final initialIndex = _percentages.indexOf(_selectedPercentage);
    _percentageController = FixedExtentScrollController(
      initialItem: initialIndex >= 0 ? initialIndex : 6,
    );
  }

  @override
  void dispose() {
    _percentageController.dispose();
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
          _buildDescription(context),
          _buildPicker(context),
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
        'Warning',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.getTextPrimary(context),
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        'You will be warned when you reach this percentage of your daily limit',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.getTextSecondary(context),
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
        height: 150,
        child: Stack(
          children: [
            _buildSelectionHighlight(),
            _buildWheelPicker(context),
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

  Widget _buildWheelPicker(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: _percentageController,
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
        setState(() => _selectedPercentage = _percentages[index]);
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: _percentages.length,
        builder: (context, index) {
          return Center(
            child: Text(
              '${_percentages[index]}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextSecondary(context),
              ),
            ),
          );
        },
      ),
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
              onPressed: () {
                Navigator.pop(context, _selectedPercentage);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
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
