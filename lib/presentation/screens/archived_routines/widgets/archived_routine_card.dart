import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/routine.dart';
import '../../../providers/installed_apps_provider.dart';
import '../../routines/widgets/card/days_display.dart';

class ArchivedRoutineCard extends ConsumerWidget {
  final Routine routine;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const ArchivedRoutineCard({
    super.key,
    required this.routine,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            if (routine.description != null) ...[
              const SizedBox(height: 8),
              Text(
                routine.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.getTextSecondary(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            DaysDisplay(selectedDays: routine.days),
            const SizedBox(height: 12),
            _buildAppsRow(context, ref),
            const SizedBox(height: 16),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.archive_outlined,
          size: 18,
          color: AppColors.getTextSecondary(context),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            routine.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppsRow(BuildContext context, WidgetRef ref) {
    final displayPackages = routine.appPackages.take(4).toList();
    final remaining = routine.appPackages.length - 4;

    return Row(
      children: [
        ...displayPackages.map((packageName) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _AppIconSmall(packageName: packageName),
          );
        }),
        if (remaining > 0)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '+$remaining',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        const Spacer(),
        Text(
          '${routine.appPackages.length} apps',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onRestore,
            icon: const Icon(Icons.restore, size: 18),
            label: const Text('Restore'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppIconSmall extends ConsumerWidget {
  final String packageName;

  const _AppIconSmall({required this.packageName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider(packageName));

    return appInfo.when(
      data: (info) {
        if (info?.icon != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              info!.icon!,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          );
        }
        return _buildPlaceholder();
      },
      loading: () => _buildPlaceholder(),
      error: (_, __) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.android,
        size: 16,
        color: AppColors.primary,
      ),
    );
  }
}
