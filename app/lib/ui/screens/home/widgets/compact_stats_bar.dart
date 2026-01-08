import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';


/// Compact stats bar displaying Streak, Points, and Time in a single row
class CompactStatsBar extends StatelessWidget {
  const CompactStatsBar({
    required this.isDark,
    required this.stats,
    required this.currentStreak,
    super.key,
  });

  final bool isDark;
  final WeeklyStats stats;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity, // Full width to allow decorations to spread
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias, // Clip decorations
        child: Stack(
          children: [
            // Decorative Circle 1 (Top Right)
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Decorative Circle 2 (Bottom Left)
            Positioned(
              bottom: -15,
              left: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section Title
                  const Text(
                    'YOUR PROGRESS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Pills Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildPill(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: Colors.orange,
                          label: '$currentStreak Day',
                          bgColor: Colors.orange.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPill(
                          icon: Icons.stars_rounded,
                          iconColor: AppColors.primary,
                          label: '${stats.formattedPoints} pts',
                          bgColor: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPill(
                          icon: Icons.timer_rounded,
                          iconColor: AppColors.secondary,
                          label: _formatDuration(stats.totalDurationMinutes),
                          bgColor: AppColors.secondary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color bgColor,
  }) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // Reduced horizontal padding as it is expanded
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, // White bg for pills to pop against container
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
           if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12, // Slightly smaller
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textMainDark : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      return '${hours}h';
    }
    return '${minutes}m';
  }
}
