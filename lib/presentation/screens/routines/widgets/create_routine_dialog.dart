import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    this.existingRoutine,
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

  bool get _isEditing => widget.existingRoutine != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingRoutine != null) {
      _nameController.text = widget.existingRoutine!.name;
      _descriptionController.text = widget.existingRoutine!.description ?? '';
      _selectedDays = Set.from(widget.existingRoutine!.days);
      _selectedApps = Set.from(widget.existingRoutine!.appPackages);
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
        children: [
          Text(
            _isEditing ? 'Edit Routine' : 'New Routine',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
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
            hintText: 'Enter routine name',
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
          'Description (optional)',
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
            hintText: 'Enter description',
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

  void _saveRoutine() {
    final notifier = ref.read(routineNotifierProvider.notifier);

    final routine = Routine(
      id: widget.existingRoutine?.id ?? notifier.generateId(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      days: _selectedDays,
      appPackages: _selectedApps,
      isEnabled: widget.existingRoutine?.isEnabled ?? true,
      createdAt: widget.existingRoutine?.createdAt ?? DateTime.now(),
    );

    notifier.saveRoutine(routine);
    Navigator.pop(context);
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
}
