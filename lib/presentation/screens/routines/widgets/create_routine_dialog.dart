import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_a_break/presentation/widgets/dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/routine.dart';
import '../../../providers/routine_provider.dart';
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
                  SelectedAppsPreview(
                    selectedPackages: _selectedApps,
                    onTap: _openAppSelector,
                  ),
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
    final repo = await ref.read(routineRepositoryProvider.future);
    final routine = Routine(
      id: widget.existingRoutine?.id ?? repo.generateId(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      days: _selectedDays,
      appPackages: _selectedApps,
      isEnabled: _isEnabled,
      createdAt: widget.existingRoutine?.createdAt ?? DateTime.now(),
    );

    await repo.saveRoutine(routine);
    ref.invalidate(allRoutinesProvider);
    ref.invalidate(activeRoutinesProvider);
    ref.invalidate(archivedRoutinesProvider);

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
