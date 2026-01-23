import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/duration_extensions.dart';
import '../../../../domain/entities/app_usage.dart';
import '../../../providers/installed_apps_provider.dart';

class TopAppsList extends ConsumerWidget {
  final List<AppUsage> apps;
  final bool isLoading;
  final Function(String)? onAppTap;

  const TopAppsList({
    super.key,
    required this.apps,
    this.isLoading = false,
    this.onAppTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (apps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No usage data yet.\nStart using apps to see statistics.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.getTextSecondary(context)),
          ),
        ),
      );
    }

    final maxTime = apps.first.totalTimeInForeground;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: apps.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.getDivider(context)),
        itemBuilder: (context, index) {
          final usage = apps[index];
          final appInfo = ref.watch(appInfoProvider(usage.packageName));

          return appInfo.when(
            data: (info) => _buildAppTile(
              context: context,
              packageName: usage.packageName,
              appName: info?.appName ?? usage.packageName.split('.').last,
              icon: info?.icon,
              duration: usage.totalTimeInForeground,
              maxDuration: maxTime,
            ),
            loading: () => _buildLoadingTile(context),
            error: (_, __) => _buildAppTile(
              context: context,
              packageName: usage.packageName,
              appName: usage.packageName.split('.').last,
              icon: null,
              duration: usage.totalTimeInForeground,
              maxDuration: maxTime,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppTile({
    required BuildContext context,
    required String packageName,
    required String appName,
    required dynamic icon,
    required Duration duration,
    required Duration maxDuration,
  }) {
    final progress = maxDuration.inSeconds > 0
        ? duration.inSeconds / maxDuration.inSeconds
        : 0.0;

    return InkWell(
      onTap: onAppTap != null ? () => onAppTap!(packageName) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildAppIcon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.getSurfaceVariant(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getColorForDuration(duration),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Text(
              duration.toReadableString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(dynamic icon) {
    if (icon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          icon,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.android,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Color _getColorForDuration(Duration duration) {
    if (duration.inMinutes >= 60) return AppColors.usageHigh;
    if (duration.inMinutes >= 30) return AppColors.usageMedium;
    return AppColors.usageLow;
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.getSurfaceVariant(context),
        highlightColor: AppColors.getSurface(context),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (_, __) => _buildLoadingTile(context),
        ),
      ),
    );
  }

  Widget _buildLoadingTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(context),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(context),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
