import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/manage_tasks/manage_tasks_bloc.dart';
import 'package:ergo_life_app/blocs/manage_tasks/manage_tasks_event.dart';
import 'package:ergo_life_app/blocs/manage_tasks/manage_tasks_state.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/manage_task_item.dart';

/// Screen for managing tasks (reorder, hide/show)
class ManageTasksScreen extends StatefulWidget {
  const ManageTasksScreen({super.key});

  @override
  State<ManageTasksScreen> createState() => _ManageTasksScreenState();
}

class _ManageTasksScreenState extends State<ManageTasksScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when screen opens
    context.read<ManageTasksBloc>().add(const LoadManageTasks());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: _buildAppBar(context, isDark),
      body: BlocConsumer<ManageTasksBloc, ManageTasksState>(
        listener: (context, state) {
          if (state is ManageTasksSaved) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Changes saved successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Navigate back after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.of(
                  context,
                ).pop(true); // Return true to indicate changes were saved
              }
            });
          } else if (state is ManageTasksError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ManageTasksLoading) {
            return _buildLoading();
          } else if (state is ManageTasksLoaded || state is ManageTasksSaving) {
            final tasks = state is ManageTasksLoaded
                ? state.tasks
                : (state as ManageTasksSaving).tasks;
            final isSaving = state is ManageTasksSaving;

            return _buildTaskList(
              context,
              tasks: tasks,
              isDark: isDark,
              isSaving: isSaving,
            );
          } else if (state is ManageTasksError) {
            return _buildError(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
        ),
        onPressed: () => _handleBack(context),
      ),
      title: Text(
        'Manage Tasks',
        style: TextStyle(
          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        BlocBuilder<ManageTasksBloc, ManageTasksState>(
          builder: (context, state) {
            final hasChanges = state is ManageTasksLoaded
                ? state.hasChanges
                : false;
            final isSaving = state is ManageTasksSaving;

            if (!hasChanges || isSaving) {
              return const SizedBox(width: 80);
            }

            return TextButton(
              onPressed: () {
                context.read<ManageTasksBloc>().add(const SaveTaskChanges());
              },
              child: const Text(
                'Update',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTaskList(
    BuildContext context, {
    required List tasks,
    required bool isDark,
    required bool isSaving,
  }) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Drag to reorder, toggle to show/hide',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Reorderable list
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: tasks.length,
                onReorder: (oldIndex, newIndex) {
                  // Adjust newIndex if moving down
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  context.read<ManageTasksBloc>().add(
                    ReorderTask(oldIndex: oldIndex, newIndex: newIndex),
                  );
                },
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ManageTaskItem(
                    key: ValueKey(task.id),
                    task: task,
                    isDark: isDark,
                    onToggleVisibility: () {
                      context.read<ManageTasksBloc>().add(
                        ToggleTaskVisibility(taskId: task.id!),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        // Loading overlay when saving
        if (isSaving)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Saving changes...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ManageTasksBloc>().add(const LoadManageTasks());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    final state = context.read<ManageTasksBloc>().state;

    if (state is ManageTasksLoaded && state.hasChanges) {
      // Show confirmation dialog
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Do you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Discard'),
            ),
          ],
        ),
      ).then((discard) {
        if (discard == true) {
          Navigator.of(context).pop(false);
        }
      });
    } else {
      Navigator.of(context).pop(false);
    }
  }
}
