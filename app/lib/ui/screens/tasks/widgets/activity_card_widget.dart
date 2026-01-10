import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:intl/intl.dart';

/// Enhanced card displaying completed activity with stats and progress
class ActivityCardWidget extends StatelessWidget {
  final dynamic activity;
  final VoidCallback? onTap;

  const ActivityCardWidget({super.key, required this.activity, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getActivityIcon(),
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.taskName ??
                            activity.exerciseName ??
                            'Activity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textMainLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Completed ${_getDurationText()}',
                        style: TextStyle(
                          color: AppColors.textSubLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Check icon
                Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            // Stats row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatChip(
                  Icons.stars,
                  '${activity.pointsEarned} EP',
                  Colors.amber,
                ),
                _buildStatChip(Icons.timer, _getDurationText(), Colors.blue),
                _buildStatChip(
                  Icons.access_time,
                  _formatTime(activity.completedAt),
                  Colors.grey,
                ),
              ],
            ),
            // Magic Wipe progress (if available)
            if (activity.magicWipePercentage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: activity.magicWipePercentage! / 100,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        color: Colors.purple,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '💜 ${activity.magicWipePercentage}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon() {
    // Try to get icon from activity data
    if (activity.icon != null) {
      return activity.icon as IconData;
    }
    return Icons.fitness_center;
  }

  String _getDurationText() {
    final duration =
        activity.durationMinutes ?? activity.durationSeconds ~/ 60 ?? 0;
    if (duration < 1) {
      return '${activity.durationSeconds ?? 0}s';
    }
    return '${duration}m';
  }

  String _formatTime(dynamic timestamp) {
    try {
      DateTime dateTime;
      if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        return 'Recently';
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final activityDate = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );

      if (activityDate == today) {
        return DateFormat('h:mm a').format(dateTime);
      } else if (activityDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      } else if (now.difference(dateTime).inDays < 7) {
        return DateFormat('EEEE').format(dateTime);
      } else {
        return DateFormat('MMM d').format(dateTime);
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
