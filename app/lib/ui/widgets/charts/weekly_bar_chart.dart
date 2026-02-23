import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/chart_data_model.dart';

/// Bar chart showing EP per day for a given period.
class WeeklyBarChart extends StatelessWidget {
  final List<DailyBreakdownModel> data;
  final bool isDark;
  final String period;

  const WeeklyBarChart({
    super.key,
    required this.data,
    required this.isDark,
    this.period = 'week',
  });

  String get _title {
    return switch (period) {
      'week' => '📊 This Week',
      'month' => '📊 This Month',
      _ => '📊 All Time',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxY = data
        .map((d) => d.points.toDouble())
        .fold<double>(100, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barTouchData: _barTouchData(),
                titlesData: _titlesData(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: _barGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarTouchData _barTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) =>
            isDark ? Colors.grey.shade800 : Colors.grey.shade900,
        getTooltipItem: (group, gi, rod, ri) {
          final d = data[group.x.toInt()];
          return BarTooltipItem(
            '${d.dayLabel}\n${d.points} EP',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }

  FlTitlesData _titlesData() {
    // Show labels at intervals to prevent overlap
    final interval = data.length <= 7
        ? 1
        : data.length <= 30
        ? 5
        : 10;

    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx >= 0 && idx < data.length && idx % interval == 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  data[idx].dayLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.textSubDark
                        : AppColors.textSubLight,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _barGroups() {
    // Dynamic bar width based on data count
    final barWidth = data.length <= 7
        ? 16.0
        : data.length <= 30
        ? 8.0
        : 4.0;

    return data.asMap().entries.map((entry) {
      final isToday = entry.key == data.length - 1;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.points.toDouble(),
            width: barWidth,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            gradient: LinearGradient(
              colors: isToday
                  ? [
                      AppColors.secondary,
                      AppColors.secondary.withValues(alpha: 0.7),
                    ]
                  : [
                      AppColors.secondary.withValues(alpha: 0.4),
                      AppColors.secondary.withValues(alpha: 0.2),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      );
    }).toList();
  }
}
