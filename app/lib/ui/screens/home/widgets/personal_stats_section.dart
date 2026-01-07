import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';

/// Personal stats section when user is not in a house
class PersonalStatsSection extends StatelessWidget {
  const PersonalStatsSection({
    required this.isDark,
    required this.stats,
    super.key,
  });

  final bool isDark;
  final WeeklyStats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR PROGRESS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Weekly Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final formattedDuration = _formatDuration(stats.totalDurationMinutes);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            isDark: isDark,
            icon: Icons.stars_rounded,
            iconColor: AppColors.primary,
            value: stats.formattedPoints,
            label: 'Points',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            isDark: isDark,
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.orange,
            value: '${stats.streakDays}',
            label: 'Day Streak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            isDark: isDark,
            icon: Icons.timer_rounded,
            iconColor: AppColors.secondary,
            value: formattedDuration,
            label: 'Active',
          ),
        ),
      ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
        ],
      ),
    );
  }
}
