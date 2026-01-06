import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Empty state widget for tasks screen
class TasksEmptyState extends StatelessWidget {
  final String message;
  final bool isDark;

  const TasksEmptyState({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.bookmark_border_outlined,
              size: 64,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Create your first custom task\nto get started!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSubDark.withValues(alpha: 0.7)
                    : AppColors.textSubLight.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
