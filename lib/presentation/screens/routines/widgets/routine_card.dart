import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/routine.dart';
import '../../../providers/installed_apps_provider.dart';
import '../../../providers/routine_provider.dart';

class RoutineCard extends ConsumerWidget {
  final Routine routine;
  final VoidCallback onEdit;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onEdit,
  });

  static const List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref),
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
                _buildDaysRow(context),
                const SizedBox(height: 12),
                _buildAppsRow(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
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
        Switch(
          value: routine.isEnabled,
          onChanged: (enabled) {
            ref
                .read(routineNotifierProvider.notifier)
                .toggleRoutine(routine.id, enabled);
          },
        ),
      ],
    );
  }

  Widget _buildDaysRow(BuildContext context) {
    return Row(
      children: List.generate(7, (index) {
        final isSelected = routine.days.contains(index);
        return Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.getSurfaceVariant(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              _dayLabels[index],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextSecondary(context),
              ),
            ),
          ),
        );
      }),
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
              color: AppColors.primary.withOpacity(0.1),
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
        color: AppColors.primary.withOpacity(0.1),
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
