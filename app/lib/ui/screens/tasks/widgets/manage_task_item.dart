import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/task_model.dart';

/// Widget for individual task item in manage tasks list
class ManageTaskItem extends StatelessWidget {
  const ManageTaskItem({
    required this.task,
    required this.onToggleVisibility,
    required this.isDark,
    super.key,
  });

  final TaskModel task;
  final VoidCallback onToggleVisibility;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isHidden = task.isHidden;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: isHidden ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Drag handle
              Icon(
                Icons.drag_handle,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                size: 24,
              ),
              const SizedBox(width: 12),

              // Task icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: task.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  task.icon,
                  color: task.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Task name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.exerciseName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.taskDescription != null &&
                        task.taskDescription!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.taskDescription!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSubDark
                              : AppColors.textSubLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Toggle switch
              Switch(
                value: !isHidden,
                onChanged: (_) => onToggleVisibility(),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
