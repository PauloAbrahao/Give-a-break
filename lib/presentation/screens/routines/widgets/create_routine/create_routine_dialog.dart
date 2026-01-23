import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../domain/entities/routine.dart';
import '../../../../providers/app_limit_provider.dart';
import '../../../../providers/routine_provider.dart';
import 'bottom_sheet_handle.dart';
import '../../../../widgets/dialog.dart';
import 'app_selector_screen.dart';
import 'day_selector.dart';
import 'limits_selector.dart';
import 'routine_action_buttons.dart';
import 'routine_dialog_header.dart';
import 'routine_enabled_switch.dart';
import 'routine_text_field.dart';
import 'schedule_selector.dart';
import '../card/selected_apps_preview.dart';
import '../overlay/overlay_settings_selector.dart';

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
  String? _overlayColor;
  String? _overlayIcon;
  bool _showAdvancedSettings = false;

  bool get _isEditing => widget.existingRoutine != null;

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _selectedDays.isNotEmpty &&
      _selectedApps.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initializeFromExistingRoutine();
  }

  void _initializeFromExistingRoutine() {
    final routine = widget.existingRoutine;
    if (routine == null) return;

    _nameController.text = routine.name;
    _descriptionController.text = routine.description ?? '';
    _selectedDays = Set.from(routine.days);
    _selectedApps = Set.from(routine.appPackages);
    _isEnabled = routine.isEnabled;
    _isAllDay = routine.startTime == null;
    _dailyLimit = routine.dailyLimit;
    _dailyLimitOpenings = routine.dailyLimitOpenings;
    _overlayColor = routine.overlayColor;
    _overlayIcon = routine.overlayIcon;
    _showAdvancedSettings = routine.overlayColor != null || routine.overlayIcon != null;

    if (routine.startTime != null) {
      _startTime = _parseTime(routine.startTime!);
    }
    if (routine.endTime != null) {
      _endTime = _parseTime(routine.endTime!);
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
            const BottomSheetHandle(),
            RoutineDialogHeader(
              isEditing: _isEditing,
              onDelete: _handleDelete,
              onArchive: _handleArchive,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 24),
                  _buildDaySelector(),
                  const SizedBox(height: 24),
                  _buildScheduleSelector(),
                  const SizedBox(height: 24),
                  _buildAppsPreview(),
                  const SizedBox(height: 24),
                  _buildLimitsSelector(),
                  const SizedBox(height: 24),
                  _buildCustomSettingsSection(),
                  const SizedBox(height: 24),
                  _buildEnabledSwitch(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return RoutineTextField(
      label: 'Name',
      hint: 'Routine Name',
      controller: _nameController,
      maxLength: 20,
    );
  }

  Widget _buildDescriptionField() {
    return RoutineTextField(
      label: 'Description',
      hint: 'Routine Description',
      controller: _descriptionController,
      maxLength: 32,
      maxLines: 2,
    );
  }

  Widget _buildDaySelector() {
    return DaySelector(
      selectedDays: _selectedDays,
      onChanged: (days) => setState(() => _selectedDays = days),
    );
  }

  Widget _buildScheduleSelector() {
    return ScheduleSelector(
      isAllDay: _isAllDay,
      startTime: _startTime,
      endTime: _endTime,
      onAllDayChanged: (value) => setState(() => _isAllDay = value),
      onStartTimeChanged: (time) => setState(() => _startTime = time),
      onEndTimeChanged: (time) => setState(() => _endTime = time),
    );
  }

  Widget _buildAppsPreview() {
    return SelectedAppsPreview(
      selectedPackages: _selectedApps,
      onTap: _openAppSelector,
    );
  }

  Widget _buildLimitsSelector() {
    return LimitsSelector(
      dailyLimit: _dailyLimit,
      dailyLimitOpenings: _dailyLimitOpenings,
      onDailyLimitChanged: (value) => setState(() => _dailyLimit = value),
      onDailyOpeningsChanged: (value) => setState(() => _dailyLimitOpenings = value),
    );
  }

  Widget _buildCustomSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _showAdvancedSettings = !_showAdvancedSettings),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 20,
                  color: AppColors.getTextSecondary(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Custom Settings',
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _showAdvancedSettings ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: OverlaySettingsSelector(
              selectedColor: _overlayColor,
              selectedIcon: _overlayIcon,
              onColorChanged: (color) => setState(() => _overlayColor = color),
              onIconChanged: (icon) => setState(() => _overlayIcon = icon),
            ),
          ),
          crossFadeState: _showAdvancedSettings
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildEnabledSwitch() {
    return RoutineEnabledSwitch(
      value: _isEnabled,
      onChanged: (value) => setState(() => _isEnabled = value),
    );
  }

  Widget _buildActionButtons() {
    return ValueListenableBuilder(
      valueListenable: _nameController,
      builder: (context, _, __) {
        return RoutineActionButtons(
          isEditing: _isEditing,
          canSave: _canSave,
          onCancel: () => Navigator.pop(context),
          onSave: _saveRoutine,
        );
      },
    );
  }

  Future<void> _saveRoutine() async {
    final notifier = ref.read(routineNotifierProvider.notifier);
    final routine = Routine(
      id: widget.existingRoutine?.id ?? notifier.generateId(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      days: _selectedDays,
      appPackages: _selectedApps,
      isEnabled: _isEnabled,
      createdAt: widget.existingRoutine?.createdAt ?? DateTime.now(),
      startTime: _isAllDay ? null : _formatTime(_startTime),
      endTime: _isAllDay ? null : _formatTime(_endTime),
      dailyLimit: _dailyLimit,
      dailyLimitOpenings: _dailyLimitOpenings,
      overlayColor: _overlayColor,
      overlayIcon: _overlayIcon,
    );

    await notifier.saveRoutine(routine);
    _invalidateProviders();

    if (mounted) Navigator.pop(context);
  }

  void _invalidateProviders() {
    ref.invalidate(allRoutinesProvider);
    ref.invalidate(activeRoutinesProvider);
    ref.invalidate(archivedRoutinesProvider);
    ref.invalidate(allLimitsProvider);
  }

  Future<void> _openAppSelector() async {
    final appsInOtherRoutines = await ref.read(
      appsInRoutinesProvider(widget.existingRoutine?.id).future,
    );

    if (!mounted) return;

    final result = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => AppSelectorScreen(
          initialSelectedPackages: _selectedApps,
          appsInOtherRoutines: appsInOtherRoutines,
        ),
      ),
    );

    if (result != null) setState(() => _selectedApps = result);
  }

  void _handleArchive() {
    AppDialog.show(
      context: context,
      title: 'Archive Routine',
      content: 'Are you sure you want to archive this routine?',
      confirmText: 'Archive',
      confirmButtonColor: AppColors.primary,
      onConfirm: () async {
        await ref
            .read(routineNotifierProvider.notifier)
            .archiveRoutine(widget.existingRoutine!.id);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
    );
  }

  void _handleDelete() {
    AppDialog.show(
      context: context,
      title: 'Delete Routine',
      content: 'Are you sure you want to delete this routine?',
      confirmText: 'Delete',
      confirmButtonColor: AppColors.error,
      onConfirm: () async {
        await ref
            .read(routineNotifierProvider.notifier)
            .deleteRoutine(widget.existingRoutine!.id);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
    );
  }
}
