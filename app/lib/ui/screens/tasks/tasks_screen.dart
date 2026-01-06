import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_bloc.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_event.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_state.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/ui/widgets/ergo_coach_overlay.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/task_card_widget.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/high_priority_task_card.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/activity_card_widget.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/tasks_filter_chip.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/tasks_empty_state.dart';

class TasksScreen extends StatelessWidget {
  final TasksBloc tasksBloc;

  const TasksScreen({super.key, required this.tasksBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TasksBloc>.value(
      value: tasksBloc..add(const LoadTasks()),
      child: const TasksView(),
    );
  }
}

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: BlocConsumer<TasksBloc, TasksState>(
        listener: (context, state) {
          if (state is TasksError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () =>
                      context.read<TasksBloc>().add(const LoadTasks()),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TasksLoading) {
            return _buildLoadingState(isDark);
          }

          if (state is TasksError) {
            return _buildErrorState(context, state.message, isDark);
          }

          if (state is TasksLoaded) {
            return _buildLoadedState(context, state, isDark);
          }

          return _buildLoadingState(isDark);
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.red.shade300 : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<TasksBloc>().add(const LoadTasks()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    TasksLoaded state,
    bool isDark,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TasksBloc>().add(const RefreshTasks());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDark, state),
                if (state.highPriorityTask != null)
                  HighPriorityTaskCard(
                    task: state.highPriorityTask!,
                    onStart: () => _showErgoCoachAndNavigate(
                      context,
                      state.highPriorityTask!,
                    ),
                  ),
                _buildTasksList(context, isDark, state),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildFloatingButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, TasksLoaded state) {
    return Container(
      color: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
          .withValues(alpha: 0.95),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Missions',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TasksFilterChip(
                  label: 'Active',
                  isActive: state.currentFilter == 'active',
                  isDark: isDark,
                  onTap: () => context.read<TasksBloc>().add(
                    const FilterTasks(filter: 'active'),
                  ),
                ),
                const SizedBox(width: 8),
                TasksFilterChip(
                  label: 'Completed',
                  isActive: state.currentFilter == 'completed',
                  isDark: isDark,
                  onTap: () => context.read<TasksBloc>().add(
                    const FilterTasks(filter: 'completed'),
                  ),
                ),
                const SizedBox(width: 8),
                TasksFilterChip(
                  label: 'Saved',
                  isActive: state.currentFilter == 'saved',
                  isDark: isDark,
                  onTap: () => context.read<TasksBloc>().add(
                    const FilterTasks(filter: 'saved'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, bool isDark, TasksLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.currentFilter == 'completed'
                ? 'Recent Activities'
                : 'Available Tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 16),
          if (state.currentFilter == 'active')
            ...state.availableTasks.map(
              (task) => TaskCardWidget(
                task: task,
                isDark: isDark,
                onPlay: () => _showErgoCoachAndNavigate(context, task),
                onEdit: () => _editTask(context, task),
                onDelete: () => _deleteTask(context, task),
              ),
            ),
          if (state.currentFilter == 'completed')
            ...state.recentActivities.map(
              (activity) =>
                  ActivityCardWidget(activity: activity, isDark: isDark),
            ),
          if (state.currentFilter == 'saved')
            TasksEmptyState(message: 'No saved routines yet', isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return Semantics(
      label: 'Create new custom task',
      button: true,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add, size: 32, color: Colors.white),
          tooltip: 'Create custom task',
          onPressed: () => context.push(AppRouter.createTask),
        ),
      ),
    );
  }

  void _showErgoCoachAndNavigate(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ErgoCoachOverlay(
        task: task,
        onReady: () {
          Navigator.pop(ctx);
          context.push(AppRouter.activeSession, extra: task);
        },
        onSkip: () {
          Navigator.pop(ctx);
          context.push(AppRouter.activeSession, extra: task);
        },
      ),
    );
  }

  void _editTask(BuildContext context, TaskModel task) {
    // Navigate to CreateTaskScreen with task data to edit
    context.push(AppRouter.createTask, extra: task);
  }

  void _deleteTask(BuildContext context, TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          'Delete Task?',
          style: TextStyle(
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${task.exerciseName}"? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: Add DeleteTask event when backend is ready
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
