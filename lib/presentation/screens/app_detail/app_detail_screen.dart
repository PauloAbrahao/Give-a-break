import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../domain/entities/app_limit.dart';
import '../../providers/installed_apps_provider.dart';
import '../../providers/usage_provider.dart';
import '../../providers/app_limit_provider.dart';

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
          data: (info) => Text(info?.appName ?? 'App Details'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('App Details'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header
            _buildAppHeader(appInfo),
            const SizedBox(height: 24),

            // Today's Usage
            _buildUsageSection(usageToday, limit),
            const SizedBox(height: 24),

            // Limit Settings
            _buildLimitSection(limit),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(AsyncValue appInfo) {
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
                  info?.appName ?? widget.packageName.split('.').last,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.packageName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
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

  Widget _buildUsageSection(
    AsyncValue<Duration> usageToday,
    AsyncValue<AppLimit?> limit,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.todayUsage,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          usageToday.when(
            data: (duration) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    duration.toReadableString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  limit.when(
                    data: (appLimit) {
                      if (appLimit == null) return const SizedBox.shrink();
                      final progress = appLimit.dailyLimit.inSeconds > 0
                          ? duration.inSeconds / appLimit.dailyLimit.inSeconds
                          : 0.0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Limit: ${appLimit.dailyLimit.toReadableString()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: progress > 1
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress > 1
                                    ? AppColors.error
                                    : progress > 0.8
                                        ? AppColors.warning
                                        : AppColors.success,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error loading usage'),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitSection(AsyncValue<AppLimit?> limit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.dailyLimit,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              limit.when(
                data: (appLimit) {
                  if (appLimit != null) {
                    return Switch(
                      value: appLimit.isEnabled,
                      onChanged: (enabled) {
                        ref
                            .read(appLimitNotifierProvider.notifier)
                            .toggleLimit(widget.packageName, enabled);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          limit.when(
            data: (appLimit) {
              if (appLimit != null) {
                return Column(
                  children: [
                    _buildLimitRow(
                      'Daily limit',
                      appLimit.dailyLimit.toReadableString(),
                      () => _showTimePicker(appLimit),
                    ),
                    const SizedBox(height: 12),
                    _buildLimitRow(
                      'Warning at',
                      '${(appLimit.warningThreshold * 100).toInt()}%',
                      null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _removeLimit(),
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        label: const Text(
                          AppStrings.removeLimit,
                          style: TextStyle(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  const Text(
                    AppStrings.noLimitSet,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showTimePicker(null),
                      icon: const Icon(Icons.add),
                      label: const Text(AppStrings.setLimit),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error loading limit'),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitRow(String label, String value, VoidCallback? onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _showTimePicker(AppLimit? existingLimit) async {
    final initialHours = existingLimit?.dailyLimit.inHours ?? 0;
    final initialMinutes = existingLimit?.dailyLimit.inMinutes.remainder(60) ?? 30;

    final result = await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TimeLimitPicker(
        initialHours: initialHours,
        initialMinutes: initialMinutes,
      ),
    );

    if (result != null) {
      final newLimit = AppLimit(
        packageName: widget.packageName,
        dailyLimit: result,
        warningThreshold: existingLimit?.warningThreshold ?? 0.8,
        cooldownPeriod:
            existingLimit?.cooldownPeriod ?? const Duration(minutes: 5),
        isEnabled: true,
      );
      ref.read(appLimitNotifierProvider.notifier).setLimit(newLimit);
    }
  }

  void _removeLimit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Limit'),
        content: const Text('Are you sure you want to remove this limit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(appLimitNotifierProvider.notifier)
                  .removeLimit(widget.packageName);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _TimeLimitPicker extends StatefulWidget {
  final int initialHours;
  final int initialMinutes;

  const _TimeLimitPicker({
    required this.initialHours,
    required this.initialMinutes,
  });

  @override
  State<_TimeLimitPicker> createState() => _TimeLimitPickerState();
}

class _TimeLimitPickerState extends State<_TimeLimitPicker> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late int _selectedHours;
  late int _selectedMinutes;

  // Hours: 0-12, Minutes: 0-59
  static const int _maxHours = 12;
  static const int _maxMinutes = 59;

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.initialHours.clamp(0, _maxHours);
    _selectedMinutes = widget.initialMinutes.clamp(0, _maxMinutes);
    _hoursController = FixedExtentScrollController(initialItem: _selectedHours);
    _minutesController = FixedExtentScrollController(initialItem: _selectedMinutes);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Set App Limits',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Picker section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  // Selection highlight
                  Center(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  // Pickers
                  Row(
                    children: [
                      // Hours picker
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _hoursController,
                          itemExtent: 44,
                          physics: const FixedExtentScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          perspective: 0.003,
                          diameterRatio: 1.5,
                          useMagnifier: true,
                          magnification: 1.1,
                          overAndUnderCenterOpacity: 0.5,
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedHours = index);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: _maxHours + 1,
                            builder: (context, index) {
                              return Center(
                                child: Text(
                                  '$index ${index == 1 ? 'hour' : 'hours'}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Separator
                      const Text(
                        ':',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Minutes picker
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _minutesController,
                          itemExtent: 44,
                          physics: const FixedExtentScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          perspective: 0.003,
                          diameterRatio: 1.5,
                          useMagnifier: true,
                          magnification: 1.1,
                          overAndUnderCenterOpacity: 0.5,
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedMinutes = index);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: _maxMinutes + 1,
                            builder: (context, index) {
                              return Center(
                                child: Text(
                                  '$index ${index == 1 ? 'minute' : 'minutes'}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Quick select buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickSelectButton(0, 15),
                _buildQuickSelectButton(0, 30),
                _buildQuickSelectButton(1, 0),
                _buildQuickSelectButton(2, 0),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedHours == 0 && _selectedMinutes == 0
                        ? null
                        : () {
                            Navigator.pop(
                              context,
                              Duration(
                                hours: _selectedHours,
                                minutes: _selectedMinutes,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Set Limit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectButton(int hours, int minutes) {
    final isSelected = _selectedHours == hours && _selectedMinutes == minutes;
    String label;
    if (hours == 0) {
      label = '$minutes min';
    } else if (minutes == 0) {
      label = '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else {
      label = '${hours}h ${minutes}m';
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHours = hours;
          _selectedMinutes = minutes;
        });
        _hoursController.animateToItem(
          hours,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _minutesController.animateToItem(
          minutes,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFF3A3A3C)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
