import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/routine_provider.dart';
import '../archived_routines/archived_routines_screen.dart';
import 'widgets/create_routine_dialog.dart';
import 'widgets/routine_card.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(activeRoutinesProvider);
    final archivedAsync = ref.watch(archivedRoutinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Routines',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArchivedRoutinesScreen()),
            ),
            icon: Icon(
              Icons.archive_outlined,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
      body: routinesAsync.when(
        data: (routines) {
          final archivedCount = archivedAsync.valueOrNull?.length ?? 0;
          if (routines.isEmpty) {
            return _buildEmptyState(context, archivedCount);
          }
          return _buildRoutinesList(context, ref, routines, archivedCount);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            'Error loading routines',
            style: TextStyle(color: AppColors.getTextSecondary(context)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRoutineDialog(context, null),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, int archivedCount) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 64,
                  color: AppColors.getTextSecondary(
                    context,
                  ).withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No routines yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a routine to manage your app usage',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showCreateRoutineDialog(context, null),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Routine'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (archivedCount > 0) _buildArchivedLink(context, archivedCount),
      ],
    );
  }

  Widget _buildRoutinesList(
    BuildContext context,
    WidgetRef ref,
    List<Routine> routines,
    int archivedCount,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return RoutineCard(
                routine: routine,
                onEdit: () => _showCreateRoutineDialog(context, routine),
              );
            },
          ),
        ),
        if (archivedCount > 0) _buildArchivedLink(context, archivedCount),
      ],
    );
  }

  Widget _buildArchivedLink(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ArchivedRoutinesScreen()),
        ),
        child: Text(
          'Archived ($count)',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(context),
          ),
        ),
      ),
    );
  }

  void _showCreateRoutineDialog(BuildContext context, Routine? routine) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateRoutineDialog(existingRoutine: routine),
    );
  }
}
