import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/routine.dart';
import '../../../providers/installed_apps_provider.dart';
import 'days_display.dart';

class RoutineCard extends ConsumerWidget {
  final Routine routine;
  final VoidCallback onEdit;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onEdit,
  });

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
                DaysDisplay(selectedDays: routine.days),
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
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: routine.isEnabled ? AppColors.success : Colors.grey,
          ),
        ),
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
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
          onPressed: onEdit,
          icon: Icon(
            Icons.edit_outlined,
            size: 20,
            color: AppColors.success,
          ),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(36, 36),
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
