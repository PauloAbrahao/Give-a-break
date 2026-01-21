import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_a_break/presentation/providers/app_limit_provider.dart';
import 'package:give_a_break/presentation/widgets/dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/duration_extensions.dart';
import '../../../../domain/entities/routine.dart';
import '../../../providers/routine_provider.dart';
import '../../app_detail/widgets/time_limit_picker.dart';
import '../../app_detail/widgets/daily_openings_picker.dart';
import 'app_selector_screen.dart';
import 'day_selector.dart';
import 'routine_dialog_header.dart';
import 'routine_enabled_switch.dart';
import 'routine_text_field.dart';
import 'selected_apps_preview.dart';

class CreateRoutineDialog extends ConsumerStatefulWidget {
  final Routine? existingRoutine;

  const CreateRoutineDialog({super.key, required this.existingRoutine});

  @override
  ConsumerState<CreateRoutineDialog> createState() => _CreateRoutineDialogState();
}

class _CreateRoutineDialogState extends ConsumerState<CreateRoutineDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Set<int> _selectedDays = {0, 1, 2, 3, 4, 5, 6};
  Set<String> _selectedApps = {};
  bool _isEnabled = true;
  bool _isAllDay = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  Duration _dailyLimit = Duration.zero;
  int _dailyLimitOpenings = 0;

  bool get _isEditing => widget.existingRoutine != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingRoutine != null) {
      _nameController.text = widget.existingRoutine!.name;
      _descriptionController.text = widget.existingRoutine!.description ?? '';
      _selectedDays = Set.from(widget.existingRoutine!.days);
      _selectedApps = Set.from(widget.existingRoutine!.appPackages);
      _isEnabled = widget.existingRoutine!.isEnabled;
      _isAllDay = widget.existingRoutine!.startTime == null;
      if (widget.existingRoutine!.startTime != null) {
        final startParts = widget.existingRoutine!.startTime!.split(':');
        _startTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
      }
      if (widget.existingRoutine!.endTime != null) {
        final endParts = widget.existingRoutine!.endTime!.split(':');
        _endTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
      }
      _dailyLimit = widget.existingRoutine!.dailyLimit;
      _dailyLimitOpenings = widget.existingRoutine!.dailyLimitOpenings;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            RoutineDialogHeader(
              isEditing: _isEditing,
              onDelete: _deleteRoutine,
              onArchive: () => _showArchiveConfirmation(context, ref),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoutineTextField(
                    label: 'Name',
                    hint: 'Routine Name',
                    controller: _nameController,
                    maxLength: 20,
                  ),
                  const SizedBox(height: 16),
                  RoutineTextField(
                    label: 'Description',
                    hint: 'Routine Description',
                    controller: _descriptionController,
                    maxLength: 90,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  DaySelector(
                    selectedDays: _selectedDays,
                    onChanged: (days) => setState(() => _selectedDays = days),
                  ),
                  const SizedBox(height: 24),
                  _buildTimeSelector(),
                  const SizedBox(height: 24),
                  SelectedAppsPreview(
                    selectedPackages: _selectedApps,
                    onTap: _openAppSelector,
                  ),
                  const SizedBox(height: 24),
                  _buildLimitsSection(),
                  const SizedBox(height: 24),
                  RoutineEnabledSwitch(
                    value: _isEnabled,
                    onChanged: (value) => setState(() => _isEnabled = value),
                  ),
                  const SizedBox(height: 32),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Schedule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('All Day', style: TextStyle(fontSize: 14, color: AppColors.getTextSecondary(context),)),
            const SizedBox(width: 8),
            Switch(
              value: _isAllDay,
              onChanged: (value) => setState(() => _isAllDay = value),
              activeThumbColor: AppColors.success,
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: !_isAllDay
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker('Start', _startTime, (time) => setState(() => _startTime = time)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimePicker('End', _endTime, (time) => setState(() => _endTime = time)),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, ValueChanged<TimeOfDay> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.getTextSecondary(context).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 14)),
            const Spacer(),
            Text(time.format(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Limits', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLimitButton(
                label: 'Daily Limit',
                value: _dailyLimit.inSeconds == 0
                    ? 'Disabled'
                    : _dailyLimit.toReadableString(),
                onTap: _showDailyLimitPicker,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLimitButton(
                label: 'Daily Opens',
                value: _dailyLimitOpenings == 0
                    ? 'Disabled'
                    : _dailyLimitOpenings.toString(),
                onTap: _showDailyOpeningsPicker,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLimitButton({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.getTextSecondary(context).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _showDailyLimitPicker() async {
    final result = await showModalBottomSheet<Duration>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TimeLimitPicker(
        initialHours: _dailyLimit.inHours,
        initialMinutes: _dailyLimit.inMinutes.remainder(60),
      ),
    );

    if (result != null) {
      setState(() => _dailyLimit = result);
    }
  }

  Future<void> _showDailyOpeningsPicker() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DailyOpeningsPicker(
        initialValue: _dailyLimitOpenings,
      ),
    );

    if (result != null) {
      setState(() => _dailyLimitOpenings = result);
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _nameController,
            builder: (context, _, __) {
              final canSave = _nameController.text.trim().isNotEmpty &&
                  _selectedDays.isNotEmpty &&
                  _selectedApps.isNotEmpty;
              return ElevatedButton(
                onPressed: canSave ? _saveRoutine : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isEditing ? 'Save' : 'Create',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _saveRoutine() async {
    final notifier = ref.read(routineNotifierProvider.notifier);
    final routine = Routine(
      id: widget.existingRoutine?.id ?? notifier.generateId(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      days: _selectedDays,
      appPackages: _selectedApps,
      isEnabled: _isEnabled,
      createdAt: widget.existingRoutine?.createdAt ?? DateTime.now(),
      startTime: _isAllDay ? null : '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
      endTime: _isAllDay ? null : '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
      dailyLimit: _dailyLimit,
      dailyLimitOpenings: _dailyLimitOpenings,
    );

    await notifier.saveRoutine(routine);
    ref.invalidate(allRoutinesProvider);
    ref.invalidate(activeRoutinesProvider);
    ref.invalidate(archivedRoutinesProvider);
    ref.invalidate(allLimitsProvider);

    if (mounted) Navigator.pop(context);
  }

  Future<void> _openAppSelector() async {
    final result = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(builder: (_) => AppSelectorScreen(initialSelectedPackages: _selectedApps)),
    );
    if (result != null) setState(() => _selectedApps = result);
  }

  void _showArchiveConfirmation(BuildContext context, WidgetRef ref) {
    AppDialog.show(
      context: context,
      title: 'Archive Routine',
      content: 'Are you sure you want to archive this routine?',
      confirmText: 'Archive',
      confirmButtonColor: AppColors.primary,
      onConfirm: () async {
        await ref.read(routineNotifierProvider.notifier).archiveRoutine(widget.existingRoutine!.id);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
    );
  }

  void _deleteRoutine() {
    AppDialog.show(
      context: context,
      title: 'Delete Routine',
      content: 'Are you sure you want to delete this routine?',
      confirmText: 'Delete',
      confirmButtonColor: AppColors.error,
      onConfirm: () async {
        final repo = await ref.read(routineRepositoryProvider.future);
        await repo.deleteRoutine(widget.existingRoutine!.id);
        ref.invalidate(allRoutinesProvider);
        ref.invalidate(activeRoutinesProvider);
        ref.invalidate(archivedRoutinesProvider);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
    );
  }
}
