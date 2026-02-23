import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/chart_data_model.dart';

/// Monthly streak calendar showing active vs missed days.
///
/// Includes `< month >` navigation header.
class StreakCalendar extends StatelessWidget {
  final List<HeatmapDataModel> data;
  final bool isDark;
  final int year;
  final int month;
  final void Function(int year, int month)? onMonthChanged;

  const StreakCalendar({
    super.key,
    required this.data,
    required this.isDark,
    required this.year,
    required this.month,
    this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Build active dates set from heatmap data
    final activeDates = <String>{};
    for (final d in data) {
      if (d.count > 0) activeDates.add(d.date);
    }

    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MonthNavigator(
            year: year,
            month: month,
            isDark: isDark,
            onMonthChanged: onMonthChanged,
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
      final date = DateTime(year, month, day);
      final dateStr = date.toIso8601String().split('T')[0];
      final isActive = activeDates.contains(dateStr);
      final isFuture = date.isAfter(now);
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

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
}

/// Month navigation with `< month >` arrows.
class _MonthNavigator extends StatelessWidget {
  final int year;
  final int month;
  final bool isDark;
  final void Function(int year, int month)? onMonthChanged;

  const _MonthNavigator({
    required this.year,
    required this.month,
    required this.isDark,
    this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canGoForward =
        year < now.year || (year == now.year && month < now.month);

    return Row(
      children: [
        Text(
          '📅 Streak Calendar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const Spacer(),
        _NavButton(
          icon: Icons.chevron_left_rounded,
          isDark: isDark,
          onTap: () => _goBack(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${_monthName(month)} $year',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          isDark: isDark,
          enabled: canGoForward,
          onTap: canGoForward ? () => _goForward() : null,
        ),
      ],
    );
  }

  void _goBack() {
    final newMonth = month == 1 ? 12 : month - 1;
    final newYear = month == 1 ? year - 1 : year;
    onMonthChanged?.call(newYear, newMonth);
  }

  void _goForward() {
    final newMonth = month == 12 ? 1 : month + 1;
    final newYear = month == 12 ? year + 1 : year;
    onMonthChanged?.call(newYear, newMonth);
  }

  String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[m - 1];
  }
}

/// Small navigation arrow button.
class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool enabled;
  final VoidCallback? onTap;

  const _NavButton({
    required this.icon,
    required this.isDark,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withAlpha((0.05 * 255).round())
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? (isDark ? AppColors.textMainDark : AppColors.textMainLight)
              : Colors.grey.shade400,
        ),
      ),
    );
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
