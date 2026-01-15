import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Motivational context bar showing streaks and encouragement
class MotivationContextBar extends StatelessWidget {
  final int currentStreak;
  final String? goalMessage;
  final bool isDark;

  const MotivationContextBar({
    super.key,
    this.currentStreak = 0,
    this.goalMessage,
    required this.isDark,
  });

  String get _encouragementMessage {
    if (goalMessage != null) return goalMessage!;

    if (currentStreak >= 7) {
      return '🔥 Amazing streak! Keep the momentum!';
    } else if (currentStreak >= 3) {
      return '💪 Great progress! Stay consistent!';
    } else if (currentStreak > 0) {
      return '⭐ You\'re on a roll! Keep it going!';
    } else {
      return '🚀 Start your journey today!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.secondary.withValues(alpha: 0.1),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          if (currentStreak > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '$currentStreak day${currentStreak > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              _encouragementMessage,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
