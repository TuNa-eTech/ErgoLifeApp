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

/// Compact stats row for active session.
///
/// Displays duration, calories, and points during a
/// session. When [currentHeartRate] is provided, a heart
/// rate indicator is shown as a fourth stat.
class CompactSessionStats extends StatelessWidget {
  final int durationMinutes;
  final int calories;
  final int points;
  final bool isDark;

  /// Current heart rate in bpm from HealthKit, or null.
  final double? currentHeartRate;

  /// HR zone label (e.g. "FAT BURN", "CARDIO").
  final String heartRateZone;

  /// EP multiplier from HR zone (e.g. 1.2, 1.5).
  final double heartRateMultiplier;

  /// Whether calories come from HealthKit (true) or
  /// from the METs estimation (false).
  final bool hasHealthData;

  const CompactSessionStats({
    super.key,
    required this.durationMinutes,
    required this.calories,
    required this.points,
    required this.isDark,
    this.currentHeartRate,
    this.heartRateZone = '',
    this.heartRateMultiplier = 1.0,
    this.hasHealthData = false,
  });

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
    );
  }

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
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Heart rate (only when HealthKit data available)
          if (currentHeartRate != null) ...[
            CompactSessionStat(
              icon: Icons.favorite,
              value: '${currentHeartRate!.round()}',
              label: heartRateZone.isNotEmpty ? heartRateZone : 'BPM',
              color: _zoneColor(),
              isDark: isDark,
            ),
            _buildDivider(),
          ],
          CompactSessionStat(
            icon: Icons.timer_outlined,
            value: '$durationMinutes min',
            label: 'DURATION',
            color: AppColors.primary,
            isDark: isDark,
          ),
          _buildDivider(),
          CompactSessionStat(
            icon: Icons.local_fire_department,
            value: '$calories',
            label: hasHealthData ? 'KCAL ♥' : 'CALORIES',
            color: AppColors.secondary,
            isDark: isDark,
          ),
          _buildDivider(),
          CompactSessionStat(
            icon: Icons.bolt,
            value: '$points',
            label: heartRateMultiplier != 1.0
                ? '${heartRateMultiplier}x EP'
                : 'POINTS',
            color: Colors.amber,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Color matching the current HR zone.
  Color _zoneColor() {
    if (currentHeartRate == null) return Colors.redAccent;
    if (currentHeartRate! < 80) return Colors.blueGrey;
    if (currentHeartRate! < 100) return Colors.green;
    if (currentHeartRate! < 130) return Colors.orange;
    return Colors.redAccent;
  }
}
