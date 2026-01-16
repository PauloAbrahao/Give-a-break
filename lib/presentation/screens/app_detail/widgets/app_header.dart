import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final AsyncValue appInfo;
  final String packageName;

  const AppHeader({
    super.key,
    required this.appInfo,
    required this.packageName,
  });

  @override
  Widget build(BuildContext context) {
    return appInfo.when(
      data: (info) => Row(
        children: [
          if (info?.icon != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                info!.icon!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.android,
                color: AppColors.primary,
                size: 36,
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info?.appName ?? packageName.split('.').last,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  packageName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextTertiary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading app info'),
    );
  }
}
