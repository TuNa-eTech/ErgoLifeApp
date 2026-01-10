import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_bloc.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_event.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_state.dart';
import 'package:ergo_life_app/data/models/task_model.dart';

import 'package:ergo_life_app/ui/screens/tasks/widgets/task_card_widget.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/high_priority_task_card.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/activity_card_widget.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/tasks_header.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/stats_summary_bar.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/tasks_loading_skeleton.dart';

class TasksScreen extends StatefulWidget {
  final TasksBloc tasksBloc;

  const TasksScreen({super.key, required this.tasksBloc});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TasksBloc>.value(
      value: widget.tasksBloc..add(const LoadTasks()),
      child: const TasksView(),
    );
  }
}

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      final filter = _tabController.index == 0 ? 'active' : 'completed';
      context.read<TasksBloc>().add(FilterTasks(filter: filter));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TasksAppBar(tabController: _tabController),
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
            return _buildLoadingState();
          }

          if (state is TasksError) {
            return _buildErrorState(context, state.message);
          }

          if (state is TasksLoaded) {
            return _buildLoadedState(context, state);
          }

          return _buildLoadingState();
        },
      ),
      floatingActionButton: SafeArea(
        child: Padding(
          // ViralBottomNavBar height (76) + margin (16) + gap (30) = 122
          padding: const EdgeInsets.only(bottom: 100),
          child: FloatingActionButton(
            onPressed: () => context.push(AppRouter.createTask),
            backgroundColor: AppColors.secondary,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return TasksLoadingSkeleton();
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textMainLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSubLight),
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

  Widget _buildLoadedState(BuildContext context, TasksLoaded state) {
    // Sync TabController with Bloc state if needed
    // Note: We use addPostFrameCallback to avoid "setState during build" if we need to animate
    if (_tabController.index == 0 && state.currentFilter == 'completed') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_tabController.index != 1) _tabController.animateTo(1);
      });
    } else if (_tabController.index == 1 && state.currentFilter == 'active') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_tabController.index != 0) _tabController.animateTo(0);
      });
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildActiveTab(context, state),
        _buildCompletedTab(context, state),
      ],
    );
  }

  Widget _buildActiveTab(BuildContext context, TasksLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TasksBloc>().add(const RefreshTasks());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatsSummaryBar(state: state),

            if (state.highPriorityTask != null)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: HighPriorityTaskCard(
                        task: state.highPriorityTask!,
                        onStart: () => _navigateToSession(
                          context,
                          state.highPriorityTask!,
                        ),
                      ),
                    ),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: AnimationLimiter(
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: state.availableTasks
                        .map(
                          (task) => TaskCardWidget(
                            task: task,
                            onPlay: () => _navigateToSession(context, task),
                            onEdit: () => _editTask(context, task),
                            onDelete: () => _deleteTask(context, task),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTab(BuildContext context, TasksLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TasksBloc>().add(const RefreshTasks());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            StatsSummaryBar(state: state),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: AnimationLimiter(
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: state.recentActivities
                        .map(
                          (activity) => ActivityCardWidget(activity: activity),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate directly to active session screen
  void _navigateToSession(BuildContext context, TaskModel task) {
    context.push(AppRouter.activeSession, extra: task);
  }

  void _editTask(BuildContext context, TaskModel task) {
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
