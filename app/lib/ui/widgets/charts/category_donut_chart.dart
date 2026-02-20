import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';

/// Donut chart showing time distribution by task.
class CategoryDonutChart extends StatelessWidget {
  final List<TopTask> topTasks;
  final bool isDark;

  const CategoryDonutChart({
    super.key,
    required this.topTasks,
    required this.isDark,
  });

  static const _colors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
  ];

  @override
  Widget build(BuildContext context) {
    if (topTasks.isEmpty) return const SizedBox.shrink();

    final totalMinutes = topTasks.fold<int>(
      0,
      (sum, t) => sum + t.totalDurationMinutes,
    );

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
            '🎯 Task Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sections: _sections(totalMinutes),
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(child: _buildLegend(totalMinutes)),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _sections(int total) {
    return topTasks.asMap().entries.map((entry) {
      final color = _colors[entry.key % _colors.length];
      final pct = total > 0 ? entry.value.totalDurationMinutes / total : 0.0;
      return PieChartSectionData(
        color: color,
        value: entry.value.totalDurationMinutes.toDouble(),
        title: '${(pct * 100).round()}%',
        radius: 24,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: topTasks.asMap().entries.map((entry) {
        final color = _colors[entry.key % _colors.length];
        final task = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.taskName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
              ),
              Text(
                task.formattedDuration,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
