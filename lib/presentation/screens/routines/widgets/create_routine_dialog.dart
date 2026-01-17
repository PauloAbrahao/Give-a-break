import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_a_break/core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/routine.dart';
import '../../../providers/routine_provider.dart';
import 'day_selector.dart';
import 'selected_apps_preview.dart';
import 'app_selector_screen.dart';

class CreateRoutineDialog extends ConsumerStatefulWidget {
  final Routine? existingRoutine;

  const CreateRoutineDialog({
    super.key,
    required this.existingRoutine,
  });

  @override
  ConsumerState<CreateRoutineDialog> createState() =>
      _CreateRoutineDialogState();
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
            _buildTitle(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameField(context),
                  const SizedBox(height: 16),
                  _buildDescriptionField(context),
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
                  _buildEnabledSwitch(context),
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

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isEditing ? 'Edit Routine' : 'New Routine',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          if (_isEditing)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: _deleteRoutine,
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.error,
                ),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Routine name',
            filled: true,
            fillColor: AppColors.getSurfaceVariant(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Description',
            filled: true,
            fillColor: AppColors.getSurfaceVariant(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnabledSwitch(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Enable routine',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (value) => setState(() => _isEnabled = value),
            activeThumbColor : AppColors.success,
          ),
        ],
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
            onPressed: _canSave() ? _saveRoutine : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isEditing ? 'Save' : 'Create',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canSave() {
    return _nameController.text.trim().isNotEmpty &&
        _selectedDays.isNotEmpty &&
        _selectedApps.isNotEmpty;
  }

  Future<void> _saveRoutine() async {
    final repo = await ref.read(routineRepositoryProvider.future);

    final routine = Routine(
      id: widget.existingRoutine?.id ?? repo.generateId(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      days: _selectedDays,
      appPackages: _selectedApps,
      isEnabled: _isEnabled,
      createdAt: widget.existingRoutine?.createdAt ?? DateTime.now(),
    );

    await repo.saveRoutine(routine);
    ref.invalidate(allRoutinesProvider);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _openAppSelector() async {
    final result = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => AppSelectorScreen(
          initialSelectedPackages: _selectedApps,
        ),
      ),
    );

    if (result != null) {
      setState(() => _selectedApps = result);
    }
  }

  void _deleteRoutine() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Routine'),
        content: const Text('Are you sure you want to remove this routine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.getTextPrimary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final repo = await ref.read(routineRepositoryProvider.future);

    await repo.deleteRoutine(widget.existingRoutine!.id);

    ref.invalidate(allRoutinesProvider);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
