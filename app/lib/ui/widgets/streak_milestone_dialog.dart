import 'package:flutter/material.dart';

/// Celebration dialog shown when reaching streak milestones
///
/// Milestones: 7, 14, 30, 60, 100 days
class StreakMilestoneDialog extends StatelessWidget {
  final int streakDays;

  const StreakMilestoneDialog({super.key, required this.streakDays});

  static const List<int> milestones = [7, 14, 30, 60, 100, 365];

  /// Check if given streak is a milestone
  static bool isMilestone(int streak) => milestones.contains(streak);

  /// Show milestone dialog if appropriate
  static Future<void> showIfMilestone(BuildContext context, int streak) async {
    if (isMilestone(streak)) {
      await showDialog(
        context: context,
        builder: (context) => StreakMilestoneDialog(streakDays: streak),
      );
    }
  }

  String get _message {
    switch (streakDays) {
      case 7:
        return 'You\'re on fire!';
      case 14:
        return 'Two weeks strong!';
      case 30:
        return 'One month champion! 🏆';
      case 60:
        return 'Incredible dedication!';
      case 100:
        return 'Century club! 🎖️';
      case 365:
        return 'ONE FULL YEAR! You\'re a legend! 👑';
      default:
        return 'Amazing work!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration emojis
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🔥', style: TextStyle(fontSize: 48)),
                SizedBox(width: 8),
                Text('🎉', style: TextStyle(fontSize: 48)),
                SizedBox(width: 8),
                Text('🔥', style: TextStyle(fontSize: 48)),
              ],
            ),
            const SizedBox(height: 24),
            // Milestone text
            Text(
              '$streakDays Day Streak!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              _message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Keep it up!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
