import 'package:flutter/material.dart';
import 'package:ergo_life_app/data/models/activity_model.dart';

/// Data holder for share card content.
class ShareCardData {
  final String taskName;
  final String duration;
  final int pointsEarned;
  final int calories;
  final int streakDays;

  const ShareCardData({
    required this.taskName,
    required this.duration,
    required this.pointsEarned,
    required this.calories,
    required this.streakDays,
  });

  /// Creates share data from session completion state.
  factory ShareCardData.fromSession({
    required ActivityModel activity,
    required int pointsEarned,
    int streakDays = 0,
    int calories = 0,
  }) {
    return ShareCardData(
      taskName: activity.taskName,
      duration: activity.formattedDuration,
      pointsEarned: pointsEarned,
      calories: calories,
      streakDays: streakDays,
    );
  }
}

/// Beautiful achievement card designed for social sharing.
///
/// Renders at a fixed size (360×480) so it produces a
/// clean image via [RepaintBoundary]. The card uses a dark
/// gradient background with vibrant accent colors.
class ShareAchievementCard extends StatelessWidget {
  final ShareCardData data;
  final GlobalKey repaintKey;

  const ShareAchievementCard({
    super.key,
    required this.data,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: SizedBox(width: 360, height: 480, child: _CardContent(data: data)),
    );
  }
}

class _CardContent extends StatelessWidget {
  final ShareCardData data;
  const _CardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Spacer(),
            _buildTaskSection(),
            const SizedBox(height: 28),
            _buildStatsRow(),
            const SizedBox(height: 20),
            if (data.streakDays > 0) _buildStreakBadge(),
            const Spacer(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(Icons.bolt, color: Color(0xFFE94560), size: 22),
        SizedBox(width: 6),
        Text(
          'WORKOUT COMPLETE',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Color(0xFFE94560),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.taskName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            data.duration,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatItem(
          icon: Icons.flash_on,
          value: '${data.pointsEarned}',
          label: 'EP',
          color: const Color(0xFFFFC107),
        ),
        const SizedBox(width: 24),
        _StatItem(
          icon: Icons.local_fire_department,
          value: '${data.calories}',
          label: 'kcal',
          color: const Color(0xFFFF6B35),
        ),
      ],
    );
  }

  Widget _buildStreakBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFE94560)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            '${data.streakDays} Day Streak',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE94560),
          ),
          child: const Icon(
            Icons.fitness_center,
            size: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'ErgoLife',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white54,
          ),
        ),
        const Spacer(),
        Text(
          _todayFormatted(),
          style: const TextStyle(fontSize: 12, color: Colors.white30),
        ),
      ],
    );
  }

  String _todayFormatted() {
    final now = DateTime.now();
    const months = [
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
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
