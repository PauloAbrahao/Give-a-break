import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/routine_provider.dart';
import '../archived_routines/archived_routines_screen.dart';
import 'widgets/create_routine/create_routine_dialog.dart';
import 'widgets/card/routine_card.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(activeRoutinesProvider);
    final archivedAsync = ref.watch(archivedRoutinesProvider);
    final currentlyRunningAsync = ref.watch(currentlyRunningRoutinesProvider);
    final upcomingAsync = ref.watch(upcomingRoutinesProvider);
    final disabledAsync = ref.watch(disabledRoutinesProvider);

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
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.archive_outlined,
                  color: AppColors.getTextSecondary(context),
                ),
                if ((archivedAsync.valueOrNull?.length ?? 0) > 0)
                  Positioned(
                    right: 0.5,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: routinesAsync.when(
        data: (routines) {
          if (routines.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildSectionedList(
            context,
            ref,
            currentlyRunning: currentlyRunningAsync.valueOrNull ?? [],
            upcoming: upcomingAsync.valueOrNull ?? [],
            disabled: disabledAsync.valueOrNull ?? [],
          );
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionedList(
    BuildContext context,
    WidgetRef ref, {
    required List<Routine> currentlyRunning,
    required List<Routine> upcoming,
    required List<Routine> disabled,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (currentlyRunning.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            title: 'Active Now',
            icon: Icons.play_circle_outline,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          ...currentlyRunning.map(
            (routine) => RoutineCard(
              routine: routine,
              onEdit: () => _showCreateRoutineDialog(context, routine),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (upcoming.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            title: 'Upcoming',
            icon: Icons.schedule_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          ...upcoming.map(
            (routine) => RoutineCard(
              routine: routine,
              onEdit: () => _showCreateRoutineDialog(context, routine),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (disabled.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            title: 'Disabled',
            icon: Icons.pause_circle_outline,
            color: AppColors.getTextSecondary(context),
          ),
          const SizedBox(height: 12),
          ...disabled.map(
            (routine) => Opacity(
              opacity: 0.6,
              child: RoutineCard(
                routine: routine,
                onEdit: () => _showCreateRoutineDialog(context, routine),
              ),
            ),
          ),
        ],
        if (currentlyRunning.isEmpty && upcoming.isEmpty && disabled.isEmpty)
          _buildNoActiveRoutines(context),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildNoActiveRoutines(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No routines scheduled',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your routines will appear here when active',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
              ),
            ),
          ],
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
