import 'package:flutter/material.dart';

/// Modern celebration dialog for streak milestones
class StreakMilestoneDialog extends StatelessWidget {
  final int streakDays;

  const StreakMilestoneDialog({super.key, required this.streakDays});

  static const List<int> milestones = [7, 14, 30, 60, 100, 365];

  /// Check if given streak is a milestone
  static bool isMilestone(int streak) => milestones.contains(streak);

  static Future<void> showIfMilestone(BuildContext context, int streak) async {
    if (isMilestone(streak)) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StreakMilestoneDialog(streakDays: streak),
      );
    }
  }

  String get _message {
    switch (streakDays) {
      case 7:
        return 'You\'re on fire! Keep up the amazing work!';
      case 14:
        return 'Two weeks of consistency! You\'re building a great habit!';
      case 30:
        return 'One month champion! You\'ve proven your dedication!';
      case 60:
        return 'Incredible dedication! 60 days of excellence!';
      case 100:
        return 'Welcome to the Century Club! Outstanding achievement!';
      case 365:
        return 'ONE FULL YEAR! You\'re an absolute legend!';
      default:
        return 'Amazing work! Keep it up!';
    }
  }

  String get _emoji {
    if (streakDays >= 365) return '👑';
    if (streakDays >= 100) return '🎖️';
    if (streakDays >= 30) return '🏆';
    return '🔥';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.4),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildContent(isDark),
            _buildButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        children: [
          // Celebration emojis
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🔥', style: TextStyle(fontSize: 40)),
              SizedBox(width: 8),
              Text(_emoji, style: TextStyle(fontSize: 56)),
              SizedBox(width: 8),
              Text('🔥', style: TextStyle(fontSize: 40)),
            ],
          ),
          const SizedBox(height: 20),
          // Streak text
          Text(
            '$streakDays DAY',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'STREAK!',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _message,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Days', streakDays.toString()),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildStat('Next', _getNextMilestone().toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.deepOrange.shade600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Keep Going! 💪',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  int _getNextMilestone() {
    for (final milestone in milestones) {
      if (milestone > streakDays) return milestone;
    }
    return streakDays + 100; // If past all milestones
  }
}
