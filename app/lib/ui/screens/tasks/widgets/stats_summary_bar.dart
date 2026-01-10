import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_state.dart';

/// Compact stats summary bar showing context-aware statistics
class StatsSummaryBar extends StatelessWidget {
  final TasksLoaded state;

  const StatsSummaryBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(children: _buildStats()),
    );
  }

  List<Widget> _buildStats() {
    if (state.currentFilter == 'active') {
      return [
        _StatPill(
          icon: Icons.task_alt,
          value: '${state.completedToday}/${state.totalTasks}',
          label: 'Today',
          color: Colors.green,
          isDark: false,
        ),
        const SizedBox(width: 6),
        _StatPill(
          icon: Icons.timer_outlined,
          value: '${state.focusMinutesToday}m',
          label: 'Focus',
          color: Colors.blue,
          isDark: false,
        ),
        const SizedBox(width: 6),
        _StatPill(
          icon: Icons.local_fire_department,
          value: '${state.currentStreak}d',
          label: 'Streak',
          color: Colors.orange,
          isDark: false,
        ),
      ];
    } else {
      // Completed stats
      return [
        _StatPill(
          icon: Icons.done_all,
          value: '${state.totalCompleted}',
          label: 'Done',
          color: Colors.green,
          isDark: false,
        ),
        const SizedBox(width: 6),
        _StatPill(
          icon: Icons.stars,
          value: '${state.totalEPEarned}',
          label: 'EP',
          color: Colors.amber,
          isDark: false,
        ),
        const SizedBox(width: 6),
        _StatPill(
          icon: Icons.schedule,
          value: '${state.totalMinutes}m',
          label: 'Time',
          color: Colors.blue,
          isDark: false,
        ),
      ];
    }
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
