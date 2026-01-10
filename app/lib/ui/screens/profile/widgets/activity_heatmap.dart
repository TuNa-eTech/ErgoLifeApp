import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Activity data for a single day
class DayActivity {
  final DateTime date;
  final int activityCount;

  const DayActivity({required this.date, required this.activityCount});

  /// Get color intensity based on activity count
  Color getColor(bool isDark) {
    if (activityCount == 0) {
      return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    } else if (activityCount <= 2) {
      return isDark
          ? AppColors.secondary.withValues(alpha: 0.3)
          : AppColors.secondary.withValues(alpha: 0.2);
    } else if (activityCount <= 4) {
      return isDark
          ? AppColors.secondary.withValues(alpha: 0.6)
          : AppColors.secondary.withValues(alpha: 0.5);
    } else {
      return AppColors.secondary;
    }
  }

  /// Get activity level label
  String get levelLabel {
    if (activityCount == 0) return 'No activity';
    if (activityCount == 1) return '1 activity';
    return '$activityCount activities';
  }
}

/// Professional activity heatmap component (GitHub-style)
class ActivityHeatmap extends StatefulWidget {
  final bool isDark;
  final int days;

  const ActivityHeatmap({super.key, required this.isDark, this.days = 14});

  @override
  State<ActivityHeatmap> createState() => _ActivityHeatmapState();
}

class _ActivityHeatmapState extends State<ActivityHeatmap> {


  @override
  Widget build(BuildContext context) {
    // Determine cell size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    // We want to fit 14 columns (approx 2 weeks) plus gaps
    // Available width = screenWidth - (padding * 2)
    final availableWidth = screenWidth - 48; // 24 horiz padding from profile screen
    final cellSize = (availableWidth / 15).clamp(12.0, 24.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 20,
                color: widget.isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
              const SizedBox(width: 8),
              Text(
                'Activity History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Heatmap Grid
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: cellSize * 7 + 12, // 7 days + gaps
                child: Row(
                  children: [
                    // Day Labels
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['M', 'W', 'F'].map((day) => SizedBox(
                        height: cellSize,
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.isDark ? AppColors.textSubDark : AppColors.textSubLight,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(width: 8),
                    // The Grid
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        reverse: true, // Show newest on right
                        itemCount: widget.days,
                        separatorBuilder: (_, __) => const SizedBox(width: 4),
                        itemBuilder: (context, colIndex) {
                          // colIndex 0 is the RIGHTMOST column (newest)
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (rowIndex) {
                              // Mock intensity for visual purposes
                              final intensity = _getMockIntensity(colIndex * 7 + rowIndex);
                              return Container(
                                width: cellSize,
                                height: cellSize,
                                decoration: BoxDecoration(
                                  color: _getColorForIntensity(intensity),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: TextStyle(fontSize: 10, color: widget.isDark ? Colors.grey : Colors.grey.shade600),
              ),
              const SizedBox(width: 4),
              _buildLegendItem(0),
              const SizedBox(width: 2),
              _buildLegendItem(1),
              const SizedBox(width: 2),
              _buildLegendItem(2),
              const SizedBox(width: 2),
              _buildLegendItem(3),
              const SizedBox(width: 2),
              _buildLegendItem(4),
              const SizedBox(width: 4),
              Text(
                'More',
                style: TextStyle(fontSize: 10, color: widget.isDark ? Colors.grey : Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(int level) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _getColorForIntensity(level),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  int _getMockIntensity(int seed) {
    // Generate semi-random consistency for "better" look
    if (seed % 9 == 0) return 0;
    if (seed % 3 == 0) return 4;
    if (seed % 2 == 0) return 2;
    return 1;
  }

  Color _getColorForIntensity(int intensity) {
    if (intensity == 0) {
      return widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    }

    final baseColor = AppColors.secondary;
    // Simple intensity mapping
    switch (intensity) {
      case 1:
        return baseColor.withValues(alpha: 0.3);
      case 2:
        return baseColor.withValues(alpha: 0.5);
      case 3:
        return baseColor.withValues(alpha: 0.7);
      case 4:
      default:
        return baseColor;
    }
  }
}
