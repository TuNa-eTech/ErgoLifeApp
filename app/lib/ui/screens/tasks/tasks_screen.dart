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
                  _buildHighPriorityTask(
                    context,
                    isDark,
                    state.highPriorityTask!,
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
                _buildFilterChip(context, 'Active', 'active', state, isDark),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Completed',
                  'completed',
                  state,
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Saved', 'saved', state, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String filter,
    TasksLoaded state,
    bool isDark,
  ) {
    final isActive = state.currentFilter == filter;
    return GestureDetector(
      onTap: () => context.read<TasksBloc>().add(FilterTasks(filter: filter)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.secondary
              : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHighPriorityTask(
    BuildContext context,
    bool isDark,
    TaskModel task,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6A00), Color(0xFFEE0979)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6A00).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(task.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HIGH PRIORITY',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                task.exerciseName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.taskDescription ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showErgoCoachAndNavigate(context, task),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF6A00),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow),
                          SizedBox(width: 8),
                          Text(
                            'Start Now',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
              (task) => _buildTaskCard(context, isDark, task),
            ),
          if (state.currentFilter == 'completed')
            ...state.recentActivities.map(
              (activity) => _buildActivityCard(context, isDark, activity),
            ),
          if (state.currentFilter == 'saved')
            _buildEmptyState(isDark, 'No saved routines yet'),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, bool isDark, TaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: task.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(task.icon, color: task.color, size: 28),
        ),
        title: Text(
          task.exerciseName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        subtitle: Text(
          task.taskDescription ?? '',
          style: TextStyle(
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.play_circle_fill,
            color: AppColors.secondary,
            size: 32,
          ),
          onPressed: () => _showErgoCoachAndNavigate(context, task),
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    bool isDark,
    dynamic activity,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.exerciseName ?? 'Activity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity.pointsEarned} EP earned',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSubDark
                        : AppColors.textSubLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
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
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return Container(
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
        onPressed: () => context.push(AppRouter.createTask),
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
}
