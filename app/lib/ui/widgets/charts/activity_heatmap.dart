import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/chart_data_model.dart';

/// GitHub-style activity heatmap using CustomPainter.
class ActivityHeatmap extends StatelessWidget {
  final List<HeatmapDataModel> data;
  final bool isDark;

  const ActivityHeatmap({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

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
            '🔥 Activity Heatmap',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: CustomPaint(
              size: const Size(720, 100),
              painter: _HeatmapPainter(data: data, isDark: isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final colors = _intensityColors(isDark);
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
            margin: const EdgeInsets.symmetric(horizontal: 1),
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

List<Color> _intensityColors(bool isDark) {
  if (isDark) {
    return const [
      Color(0xFF161B22),
      Color(0xFF0E4429),
      Color(0xFF006D32),
      Color(0xFF26A641),
      Color(0xFF39D353),
    ];
  }
  return const [
    Color(0xFFEBEDF0),
    Color(0xFF9BE9A8),
    Color(0xFF40C463),
    Color(0xFF30A14E),
    Color(0xFF216E39),
  ];
}

class _HeatmapPainter extends CustomPainter {
  final List<HeatmapDataModel> data;
  final bool isDark;

  _HeatmapPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 12.0;
    const gap = 2.0;
    const step = cellSize + gap;
    final colors = _intensityColors(isDark);

    // Build date → intensity map
    final map = <String, int>{};
    for (final d in data) {
      map[d.date] = d.intensity;
    }

    // Start from first data point
    if (data.isEmpty) return;
    var cursor = DateTime.parse(data.first.date);
    final end = DateTime.parse(data.last.date);

    var col = 0;
    while (cursor.isBefore(end) || cursor.isAtSameMomentAs(end)) {
      final row = cursor.weekday - 1;
      final key = cursor.toIso8601String().split('T')[0];
      final intensity = map[key] ?? 0;
      final color = colors[intensity.clamp(0, 4)];

      final rect = Rect.fromLTWH(col * step, row * step, cellSize, cellSize);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = color,
      );

      // Advance to next day
      cursor = cursor.add(const Duration(days: 1));
      if (cursor.weekday == 1) col++;
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter old) =>
      old.data != data || old.isDark != isDark;
}
