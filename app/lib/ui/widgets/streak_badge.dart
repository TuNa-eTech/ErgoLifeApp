import 'package:flutter/material.dart';

/// Streak Badge widget displaying current streak and freeze count
/// 
/// Automatically hidden when currentStreak is 0
class StreakBadge extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int streakFreezeCount;
  final VoidCallback? onTap;

  const StreakBadge({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.streakFreezeCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Hide badge if no streak
    if (currentStreak == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B00), Color(0xFFFF8C42)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Fire emoji
            const Text(
              '🔥',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            // Streak info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$currentStreak ${_dayText(currentStreak)} Streak',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your longest: $longestStreak ${_dayText(longestStreak)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
            // Freeze count
            if (streakFreezeCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🛡️',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'x$streakFreezeCount',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _dayText(int days) => days == 1 ? 'Day' : 'Days';
}
