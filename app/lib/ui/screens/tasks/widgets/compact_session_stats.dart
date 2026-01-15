import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Compact stat item for active session
class CompactSessionStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const CompactSessionStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Compact stats row for active session
class CompactSessionStats extends StatelessWidget {
  final int durationMinutes;
  final int calories;
  final int points;
  final bool isDark;

  const CompactSessionStats({
    super.key,
    required this.durationMinutes,
    required this.calories,
    required this.points,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CompactSessionStat(
            icon: Icons.timer_outlined,
            value: '$durationMinutes min',
            label: 'DURATION',
            color: AppColors.primary,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
          CompactSessionStat(
            icon: Icons.local_fire_department,
            value: '$calories',
            label: 'CALORIES',
            color: AppColors.secondary,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
          CompactSessionStat(
            icon: Icons.bolt,
            value: '$points',
            label: 'POINTS',
            color: Colors.amber,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
