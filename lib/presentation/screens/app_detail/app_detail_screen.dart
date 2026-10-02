import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_a_break/presentation/screens/import_settings/widgets/result_snackbar.dart';
import 'package:give_a_break/presentation/widgets/dialog.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../domain/entities/app_limit.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/data_transfer_provider.dart';
import '../../providers/installed_apps_provider.dart';
import '../../providers/usage_provider.dart';
import '../../providers/app_limit_provider.dart';
import '../../providers/routine_provider.dart';
import 'widgets/app_header.dart';
import 'widgets/usage_section.dart';
import 'widgets/limit_section.dart';
import 'widgets/time_limit_picker.dart';
import 'widgets/daily_openings_picker.dart';

class AppDetailScreen extends ConsumerStatefulWidget {
  final String packageName;

  const AppDetailScreen({super.key, required this.packageName});

  @override
  ConsumerState<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends ConsumerState<AppDetailScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshUsage());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshUsage();
    }
  }

  void _refreshUsage() {
    if (!mounted) return;
    ref.invalidate(todayUsageProvider);
  }

  @override
  Widget build(BuildContext context) {
    final appInfo = ref.watch(appInfoProvider(widget.packageName));
    final usageToday = ref.watch(appUsageFullTodayProvider(widget.packageName));
    final limit = ref.watch(appLimitProvider(widget.packageName));
    final activeRoutine = ref.watch(
      appActiveRoutineProvider(widget.packageName),
    );

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
            AppHeader(appInfo: appInfo, packageName: widget.packageName),
            const SizedBox(height: 24),
            UsageSection(
              usageToday: usageToday,
              limit: limit,
              activeRoutine: activeRoutine,
            ),
            const SizedBox(height: 4),
            activeRoutine.when(
              data: (routine) {
                if (routine != null) {
                  return _buildRoutineManagedSection(routine);
                }
                return LimitSection(
                  limit: limit,
                  onToggleLimit: (enabled) {
                    ref
                        .read(appLimitNotifierProvider.notifier)
                        .toggleLimit(widget.packageName, enabled);
                  },
                  onEditLimit: () => _showTimePicker(limit.valueOrNull),
                  onEditDailyOpenings: (appLimit) =>
                      _showDailyOpeningsPicker(appLimit),
                  onRemoveLimit: _removeLimit,
                  onSetLimit: () => _showTimePicker(null),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineManagedSection(Routine routine) {
    final hasTimeLimit = routine.dailyLimit.inSeconds > 0;
    final hasOpenLimit = routine.dailyLimitOpenings > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Managed by "${routine.name}"',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This app is part of an active routine. To edit limits, go to the routine settings or disable the routine.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          if (hasTimeLimit || hasOpenLimit) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (hasTimeLimit)
                  _buildLimitChip(
                    'Daily Limit: ${routine.dailyLimit.toReadableString()}',
                  ),
                if (hasOpenLimit)
                  _buildLimitChip('Daily Opens: ${routine.dailyLimitOpenings}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLimitChip(String label) {
    return Container(
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
      final newLimit = existingLimit != null
          ? existingLimit.copyWith(dailyLimit: result)
          : AppLimit(packageName: widget.packageName, dailyLimit: result);

      if (newLimit.dailyLimit.inSeconds == 0 &&
          newLimit.dailyLimitOpenings == 0) {
        ref
            .read(appLimitNotifierProvider.notifier)
            .toggleLimit(widget.packageName, false);

        if (mounted) {
          showResultSnackBar(
            context,
            const DataTransferResult(
              success: false,
              message: 'Limit not set. Please set a valid time or daily openings.',
            ),
          );
        }
      } else {
        ref.read(appLimitNotifierProvider.notifier).setLimit(newLimit);
      }
    }
  }

  Future<void> _showDailyOpeningsPicker(AppLimit existingLimit) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          DailyOpeningsPicker(initialValue: existingLimit.dailyLimitOpenings),
    );

    if (result != null) {
      final newLimit = existingLimit.copyWith(dailyLimitOpenings: result);

      if (newLimit.dailyLimit.inSeconds == 0 &&
          newLimit.dailyLimitOpenings == 0) {
        ref
            .read(appLimitNotifierProvider.notifier)
            .toggleLimit(widget.packageName, false);

        if (mounted) {
          showResultSnackBar(
            context,
            const DataTransferResult(
              success: false,
              message: 'Limit not set. Please set a valid time or daily openings.',
            ),
          );
        }
      } else {
        ref.read(appLimitNotifierProvider.notifier).setLimit(newLimit);
      }
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
