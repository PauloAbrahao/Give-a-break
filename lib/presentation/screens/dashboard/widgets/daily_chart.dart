import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/duration_extensions.dart';
import '../../../../domain/entities/daily_usage_summary.dart';

class DailyChart extends StatelessWidget {
  final List<DailyUsageSummary> summaries;
  final bool isLoading;

  const DailyChart({
    super.key,
    required this.summaries,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxHours = summaries
        .map((s) => s.totalScreenTime.toHours())
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxHours + 1).ceilToDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.getTextPrimary(context),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final summary = summaries[group.x.toInt()];
                      return BarTooltipItem(
                        summary.totalScreenTime.toReadableString(),
                        const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}h',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.getTextTertiary(context),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= summaries.length) {
                          return const SizedBox.shrink();
                        }
                        final date = summaries[index].date;
                        final isToday = _isToday(date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            isToday ? 'Today' : DateFormat('E').format(date),
                            style: TextStyle(
                              fontSize: 10,
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.getTextTertiary(context),
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.getSurfaceVariant(context),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: summaries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final summary = entry.value;
                  final isToday = _isToday(summary.date);

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: summary.totalScreenTime.toHours(),
                        color: isToday
                            ? AppColors.primary
                            : AppColors.primaryLight.withValues(alpha: 0.5),
                        width: 24,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.getSurfaceVariant(context),
        highlightColor: AppColors.getSurface(context),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.getSurfaceVariant(context),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
