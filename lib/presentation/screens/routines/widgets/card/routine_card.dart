import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/extensions/routine_extensions.dart';
import '../../../../../domain/entities/routine.dart';
import '../../../../providers/installed_apps_provider.dart';
import '../overlay/overlay_icon_option.dart';
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
                const SizedBox(height: 20),
                _buildAppsRow(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final iconAsset = OverlayIconOption.getAssetForIcon(routine.overlayIcon);
    final accentColor = _parseColor(routine.overlayColor);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: iconAsset != null
                ? SvgPicture.asset(
                    iconAsset,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      accentColor,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(
                    Icons.schedule,
                    size: 22,
                    color: accentColor,
                  ),
          ),
        ),
        Expanded(
          child: Row(
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
            ],
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

  Color _parseColor(String? hex) {
    if (hex == null) return AppColors.primary;
    final hexColor = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  Widget _buildAppsRow(BuildContext context, WidgetRef ref) {
    final displayPackages = routine.appPackages.take(4).toList();
    final remaining = routine.appPackages.length - 4;
    const double iconSize = 28;
    const double overlap = 8;

    final totalWidth = displayPackages.isEmpty
        ? 0.0
        : iconSize + (displayPackages.length - 1) * (iconSize - overlap) +
            (remaining > 0 ? (iconSize - overlap) : 0);

    return Row(
      children: [
        SizedBox(
          width: totalWidth,
          height: iconSize,
          child: Stack(
            children: [
              ...displayPackages.asMap().entries.map((entry) {
                final index = entry.key;
                final packageName = entry.value;
                return Positioned(
                  left: index * (iconSize - overlap),
                  child: _AppIconSmall(packageName: packageName),
                );
              }),
              if (remaining > 0)
                Positioned(
                  left: displayPackages.length * (iconSize - overlap),
                  child: Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceVariant(context),
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
                ),
            ],
          ),
        ),
        const Spacer(),
        _buildNextOccurrence(context),
      ],
    );
  }

  Widget _buildNextOccurrence(BuildContext context) {
    final nextText = routine.nextOccurrenceText;

    if (nextText == null || !routine.isEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            nextText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
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
