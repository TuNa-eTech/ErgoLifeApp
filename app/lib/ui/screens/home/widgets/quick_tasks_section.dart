import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Model class for task data
class TaskData {
  const TaskData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.ep,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String duration;
  final int ep;
}

/// Task card widget for displaying quick tasks
class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.isDark,
    required this.task,
    this.onTap,
    super.key,
  });

  final bool isDark;
  final TaskData task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildTitles(),
                const Spacer(),
                _buildDuration(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: task.iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(task.icon, color: task.iconColor, size: 22),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppColors.secondary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${task.ep}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          task.subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDuration() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252A33) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
          const SizedBox(width: 4),
          Text(
            task.duration,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick tasks section with grid of task cards
class QuickTasksSection extends StatelessWidget {
  const QuickTasksSection({
    required this.isDark,
    required this.tasks,
    this.onTaskTap,
    super.key,
  });

  final bool isDark;
  final List<TaskData> tasks;
  final void Function(TaskData task)? onTaskTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildTaskGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Quick Tasks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${tasks.length} Active',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          isDark: isDark,
          task: task,
          onTap: () => onTaskTap?.call(task),
        );
      },
    );
  }
}
