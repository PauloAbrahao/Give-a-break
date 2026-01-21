import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_a_break/presentation/widgets/dialog.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/routine_provider.dart';
import 'widgets/archived_routine_card.dart';

class ArchivedRoutinesScreen extends ConsumerWidget {
  const ArchivedRoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedRoutinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Archived Routines',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: archivedAsync.when(
        data: (routines) {
          if (routines.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildRoutinesList(context, ref, routines);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            'Error loading archived routines',
            style: TextStyle(color: AppColors.getTextSecondary(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            size: 64,
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your archive is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesList(
    BuildContext context,
    WidgetRef ref,
    List<Routine> routines,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routines.length,
      itemBuilder: (context, index) {
        final routine = routines[index];
        return ArchivedRoutineCard(
          routine: routine,
          onRestore: () => _restoreRoutine(ref, routine.id),
          onDelete: () => _showDeleteConfirmation(context, ref, routine),
        );
      },
    );
  }

  void _restoreRoutine(WidgetRef ref, String id) {
    ref.read(routineNotifierProvider.notifier).restoreRoutine(id);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) {
    AppDialog.show(
      context: context,
      title: 'Delete Routine',
      content:
          'Are you sure you want to permanently delete "${routine.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      confirmButtonColor: AppColors.error,
      onConfirm:  () {
        ref.read(routineNotifierProvider.notifier).deleteRoutine(routine.id);
        Navigator.pop(context);
      },
    );
  }
}
