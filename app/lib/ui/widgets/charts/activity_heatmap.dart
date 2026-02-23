import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/chart_data_model.dart';

/// Heatmap showing activity intensity across a year.
///
/// Includes `< year >` navigation header.
class ActivityHeatmap extends StatelessWidget {
  final List<HeatmapDataModel> data;
  final bool isDark;
  final int year;
  final ValueChanged<int>? onYearChanged;

  const ActivityHeatmap({
    super.key,
    required this.data,
    required this.isDark,
    required this.year,
    this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          _YearNavigator(
            year: year,
            isDark: isDark,
            onYearChanged: onYearChanged,
          ),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              // 53 columns (weeks) + 2px gap each
              const totalCols = 53;
              const gap = 1.5;
              final cellSize =
                  (constraints.maxWidth - (totalCols - 1) * gap) / totalCols;
              final height = 7 * cellSize + 6 * gap;

              return SizedBox(
                height: height,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, height),
                  painter: _HeatmapPainter(
                    data: data,
                    isDark: isDark,
                    year: year,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final colors = isDark
        ? [
            Colors.grey.shade800,
            const Color(0xFF1B5E20),
            const Color(0xFF388E3C),
            const Color(0xFF4CAF50),
            const Color(0xFF81C784),
          ]
        : [
            Colors.grey.shade200,
            const Color(0xFFC8E6C9),
            const Color(0xFF81C784),
            const Color(0xFF4CAF50),
            const Color(0xFF2E7D32),
          ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
        const SizedBox(width: 4),
        ...colors.map(
          (c) => Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'More',
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
      ],
    );
  }
}

/// Year navigation header with `< year >` arrows.
class _YearNavigator extends StatelessWidget {
  final int year;
  final bool isDark;
  final ValueChanged<int>? onYearChanged;

  const _YearNavigator({
    required this.year,
    required this.isDark,
    this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canGoForward = year < now.year;

    return Row(
      children: [
        Text(
          '🔥 Activity Heatmap',
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
          onTap: () => onYearChanged?.call(year - 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$year',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          isDark: isDark,
          enabled: canGoForward,
          onTap: canGoForward ? () => onYearChanged?.call(year + 1) : null,
        ),
      ],
    );
  }
}

/// Small icon button for `<` and `>` navigation.
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

class _HeatmapPainter extends CustomPainter {
  final List<HeatmapDataModel> data;
  final bool isDark;
  final int year;

  _HeatmapPainter({
    required this.data,
    required this.isDark,
    required this.year,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dataMap = <String, int>{};
    for (final d in data) {
      dataMap[d.date] = d.intensity;
    }

    // Calculate cell size from available width
    const totalCols = 53;
    const gap = 1.5;
    final cellSize = (size.width - (totalCols - 1) * gap) / totalCols;
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    final colors = isDark
        ? [
            Colors.grey.shade800,
            const Color(0xFF1B5E20),
            const Color(0xFF388E3C),
            const Color(0xFF4CAF50),
            const Color(0xFF81C784),
          ]
        : [
            Colors.grey.shade200,
            const Color(0xFFC8E6C9),
            const Color(0xFF81C784),
            const Color(0xFF4CAF50),
            const Color(0xFF2E7D32),
          ];

    var current = startDate;
    var col = 0;

    while (!current.isAfter(endDate)) {
      final row = current.weekday - 1;
      final dateStr = current.toIso8601String().split('T')[0];
      final intensity = (dataMap[dateStr] ?? 0).clamp(0, 4);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          col * (cellSize + gap),
          row * (cellSize + gap),
          cellSize,
          cellSize,
        ),
        const Radius.circular(2),
      );

      canvas.drawRRect(rect, Paint()..color = colors[intensity]);

      if (current.weekday == DateTime.sunday) {
        col++;
      }
      current = current.add(const Duration(days: 1));
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter old) =>
      old.data != data || old.isDark != isDark || old.year != year;
}
