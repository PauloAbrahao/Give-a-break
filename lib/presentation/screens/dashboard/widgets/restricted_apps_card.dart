import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_a_break/core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/app_limit.dart';
import '../../../providers/app_limit_provider.dart';
import '../../../providers/installed_apps_provider.dart';

class RestrictedAppsCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const RestrictedAppsCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitsAsync = ref.watch(allLimitsProvider);

    return limitsAsync.when(
      data: (limits) {
        final enabledLimits = limits.where((l) => l.isEnabled).take(6).toList();
        return _buildCard(context, ref, enabledLimits);
      },
      loading: () => _buildCard(context, ref, [], isLoading: true),
      error: (_, __) => _buildCard(context, ref, []),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    List<AppLimit> limits, {
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.block,
                  size: 20,
                  color: AppColors.error.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.restrictedApps,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (limits.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 32,
                        color: AppColors.getTextTertiary(context).withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No limits set',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextTertiary(context).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(child: _buildAppGrid(context, ref, limits)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppGrid(BuildContext context, WidgetRef ref, List<AppLimit> limits) {
    final displayLimits = limits.take(6).toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: displayLimits.map((limit) {
        return SizedBox(
          width: 34,
          height: 34,
          child: _AppIconWidget(packageName: limit.packageName),
        );
      }).toList(),
    );
  }
}

class _AppIconWidget extends ConsumerWidget {
  final String packageName;

  const _AppIconWidget({required this.packageName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfoAsync = ref.watch(appInfoProvider(packageName));

    return appInfoAsync.when(
      data: (appInfo) {
        if (appInfo?.icon != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              appInfo!.icon!,
              fit: BoxFit.cover,
            ),
          );
        }
        return _buildPlaceholder(context, appInfo?.appName ?? packageName);
      },
      loading: () => _buildLoadingPlaceholder(context),
      error: (_, __) => _buildPlaceholder(context, packageName),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String name) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceVariant(context),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
