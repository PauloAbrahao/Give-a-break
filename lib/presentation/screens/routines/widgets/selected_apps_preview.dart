import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../providers/installed_apps_provider.dart';

class SelectedAppsPreview extends ConsumerWidget {
  final Set<String> selectedPackages;
  final VoidCallback onTap;

  const SelectedAppsPreview({
    super.key,
    required this.selectedPackages,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Apps',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            Text(
              '${selectedPackages.length} selected',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: selectedPackages.isEmpty
                ? _buildEmptyState(context)
                : _buildAppsRow(context, ref),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_circle_outline,
          size: 20,
          color: AppColors.getTextSecondary(context),
        ),
        const SizedBox(width: 8),
        Text(
          'Tap to add apps',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAppsRow(BuildContext context, WidgetRef ref) {
    final displayPackages = selectedPackages.take(3).toList();
    final remaining = selectedPackages.length - 3;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              ...displayPackages.map((packageName) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _AppIcon(packageName: packageName),
                );
              }),
              if (remaining > 0)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+$remaining',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: AppColors.getTextSecondary(context),
        ),
      ],
    );
  }
}

class _AppIcon extends ConsumerWidget {
  final String packageName;

  const _AppIcon({required this.packageName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider(packageName));

    return appInfo.when(
      data: (info) {
        if (info?.icon != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              info!.icon!,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          );
        }
        return _buildPlaceholder(context);
      },
      loading: () => _buildPlaceholder(context),
      error: (_, __) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.android,
        size: 20,
        color: AppColors.primary,
      ),
    );
  }
}
