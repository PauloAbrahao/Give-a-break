import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_a_break/presentation/widgets/dialog.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/app_limit.dart';
import '../../providers/installed_apps_provider.dart';
import '../../providers/usage_provider.dart';
import '../../providers/app_limit_provider.dart';
import 'widgets/app_header.dart';
import 'widgets/usage_section.dart';
import 'widgets/limit_section.dart';
import 'widgets/time_limit_picker.dart';
import 'widgets/warning_threshold_picker.dart';
import 'widgets/daily_openings_picker.dart';

class AppDetailScreen extends ConsumerStatefulWidget {
  final String packageName;

  const AppDetailScreen({super.key, required this.packageName});

  @override
  ConsumerState<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends ConsumerState<AppDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final appInfo = ref.watch(appInfoProvider(widget.packageName));
    final usageToday = ref.watch(appUsageTodayProvider(widget.packageName));
    final limit = ref.watch(appLimitProvider(widget.packageName));

    return Scaffold(
      appBar: AppBar(
        title: appInfo.when(
          data: (info) => const Text(
            'App Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('App Details'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              appInfo: appInfo,
              packageName: widget.packageName,
            ),
            const SizedBox(height: 24),
            UsageSection(
              usageToday: usageToday,
              limit: limit,
            ),
            const SizedBox(height: 24),
            LimitSection(
              limit: limit,
              onToggleLimit: (enabled) {
                ref
                    .read(appLimitNotifierProvider.notifier)
                    .toggleLimit(widget.packageName, enabled);
              },
              onEditLimit: () => _showTimePicker(limit.valueOrNull),
              onEditWarning: (appLimit) => _showWarningPicker(appLimit),
              onEditDailyOpenings: (appLimit) => _showDailyOpeningsPicker(appLimit),
              onRemoveLimit: _removeLimit,
              onSetLimit: () => _showTimePicker(null),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(AppLimit? existingLimit) async {
    final initialHours = existingLimit?.dailyLimit.inHours ?? 0;
    final initialMinutes =
        existingLimit?.dailyLimit.inMinutes.remainder(60) ?? 30;

    final result = await showModalBottomSheet<Duration>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TimeLimitPicker(
        initialHours: initialHours,
        initialMinutes: initialMinutes,
      ),
    );

    if (result != null) {
      final newLimit = AppLimit(
        packageName: widget.packageName,
        dailyLimit: result,
        warningThreshold: existingLimit?.warningThreshold ?? 0.8,
        isEnabled: existingLimit?.isEnabled ?? true,
      );
      ref.read(appLimitNotifierProvider.notifier).setLimit(newLimit);
    }
  }

  Future<void> _showWarningPicker(AppLimit existingLimit) async {
    final initialPercentage = (existingLimit.warningThreshold * 100).toInt();

    final result = await showModalBottomSheet<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => WarningThresholdPicker(
        initialPercentage: initialPercentage,
        dailyLimit: existingLimit.dailyLimit,
      ),
    );

    if (result != null) {
      final newLimit = AppLimit(
        packageName: widget.packageName,
        dailyLimit: existingLimit.dailyLimit,
        warningThreshold: result / 100.0,
        isEnabled: existingLimit.isEnabled,
      );
      ref.read(appLimitNotifierProvider.notifier).setLimit(newLimit);
    }
  }

  Future<void> _showDailyOpeningsPicker(AppLimit existingLimit) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DailyOpeningsPicker(
        initialValue: existingLimit.dailyLimitOpenings,
      ),
    );

    if (result != null) {
      final newLimit = existingLimit.copyWith(dailyLimitOpenings: result);
      ref.read(appLimitNotifierProvider.notifier).setLimit(newLimit);
    }
  }

  void _removeLimit() {
    AppDialog.show(
      context: context,
      title: 'Delete Limit',
      content: 'Are you sure you want to delete this limit?',
      confirmText: 'Delete',
      confirmButtonColor: AppColors.error,
      onConfirm: () {
        ref
            .read(appLimitNotifierProvider.notifier)
            .removeLimit(widget.packageName);
        Navigator.pop(context);
      },
    );
  }
}
