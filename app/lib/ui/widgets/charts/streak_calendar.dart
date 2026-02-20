import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/chart_data_model.dart';

/// Monthly streak calendar showing active vs missed days.
class StreakCalendar extends StatelessWidget {
  final List<HeatmapDataModel> data;
  final bool isDark;

  const StreakCalendar({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Build active dates set from heatmap data
    final activeDates = <String>{};
    for (final d in data) {
      if (d.count > 0) activeDates.add(d.date);
    }

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
            '📅 ${_monthName(now.month)} ${now.year}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 12),
          _buildDayHeaders(),
          const SizedBox(height: 8),
          _buildCalendarGrid(firstDay, daysInMonth, activeDates, now),
        ],
      ),
    );
  }

  Widget _buildDayHeaders() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map(
            (d) => SizedBox(
              width: 32,
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid(
    DateTime firstDay,
    int daysInMonth,
    Set<String> activeDates,
    DateTime now,
  ) {
    final startWeekday = firstDay.weekday;
    final cells = <Widget>[];

    // Empty cells before first day
    for (int i = 1; i < startWeekday; i++) {
      cells.add(const SizedBox(width: 32, height: 32));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final dateStr = date.toIso8601String().split('T')[0];
      final isActive = activeDates.contains(dateStr);
      final isFuture = date.isAfter(now);
      final isToday = day == now.day;

      cells.add(
        _CalendarCell(
          day: day,
          isActive: isActive,
          isFuture: isFuture,
          isToday: isToday,
          isDark: isDark,
        ),
      );
    }

    return Wrap(spacing: 0, runSpacing: 4, children: cells);
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class _CalendarCell extends StatelessWidget {
  final int day;
  final bool isActive;
  final bool isFuture;
  final bool isToday;
  final bool isDark;

  const _CalendarCell({
    required this.day,
    required this.isActive,
    required this.isFuture,
    required this.isToday,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (isFuture) {
      bgColor = Colors.transparent;
      textColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    } else if (isActive) {
      bgColor = const Color(0xFF4CAF50);
      textColor = Colors.white;
    } else {
      bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
      textColor = isDark ? AppColors.textSubDark : AppColors.textSubLight;
    }

    return SizedBox(
      width: 32,
      height: 32,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppColors.secondary, width: 2)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday || isActive
                ? FontWeight.bold
                : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
