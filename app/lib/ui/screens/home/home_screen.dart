import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/home/home_bloc.dart';
import 'package:ergo_life_app/blocs/home/home_event.dart';
import 'package:ergo_life_app/blocs/home/home_state.dart';
import 'package:ergo_life_app/ui/screens/home/widgets/home_header.dart';
import 'package:ergo_life_app/ui/screens/home/widgets/arena_section.dart';
import 'package:ergo_life_app/ui/screens/home/widgets/quick_tasks_section.dart';

/// Home screen displaying user dashboard with arena and quick tasks
class HomeScreen extends StatelessWidget {
  final HomeBloc homeBloc;

  const HomeScreen({super.key, required this.homeBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>.value(
      value: homeBloc..add(const LoadHomeData()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<HomeBloc>().add(const LoadHomeData());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return _buildLoadingState(isDark);
          }

          if (state is HomeError) {
            return _buildErrorState(context, state.message, isDark);
          }

          if (state is HomeLoaded) {
            return _buildLoadedState(context, state, isDark);
          }

          return _buildLoadingState(isDark);
        },
      ),
      floatingActionButton: _buildCreateTaskButton(context),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeleton(120, 16, isDark),
                      const SizedBox(height: 8),
                      _buildSkeleton(180, 24, isDark),
                    ],
                  ),
                  _buildSkeleton(48, 48, isDark, isCircle: true),
                ],
              ),
            ),
            // Arena skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSkeleton(
                double.infinity,
                200,
                isDark,
                borderRadius: 24,
              ),
            ),
            const SizedBox(height: 24),
            // Quick tasks skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeleton(150, 20, isDark),
                  const SizedBox(height: 16),
                  ...List.generate(
                    3,
                    (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSkeleton(double.infinity, 80, isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(
    double width,
    double height,
    bool isDark, {
    double borderRadius = 12,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withOpacity(0.3)
            : Colors.grey.shade200,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark) {
    return SafeArea(
      child: Center(
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
                'Failed to load home data',
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
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<HomeBloc>().add(const LoadHomeData());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    HomeLoaded state,
    bool isDark,
  ) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(const RefreshHomeData());
          // Wait for the refresh to complete
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                isDark: isDark,
                userName: state.firstName,
                onNotificationTap: () {
                  // TODO: Handle notification tap
                },
              ),
              ArenaSection(
                isDark: isDark,
                userPoints: state.stats.totalPoints,
                rivalPoints: state.house != null && state.stats.totalPoints > 0
                    ? (state.stats.totalPoints * 0.85).toInt()
                    : 0,
                totalPoints: state.house != null
                    ? (state.stats.totalPoints * 1.3).toInt()
                    : state.stats.totalPoints,
                onLeaderboardTap: () {
                  context.go('/rank');
                },
              ),
              QuickTasksSection(
                isDark: isDark,
                tasks: _convertToTaskData(state.quickTasks),
                onTaskTap: (task) {
                  // Find the TaskModel from quick tasks
                  final taskModel = state.quickTasks.firstWhere(
                    (t) => t.exerciseName == task.title,
                    orElse: () => state.quickTasks.first,
                  );
                  _showErgoCoachAndNavigate(context, taskModel);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TaskData> _convertToTaskData(List tasks) {
    return tasks.map((task) {
      return TaskData(
        icon: task.icon,
        iconColor: task.color,
        title: task.exerciseName,
        subtitle: task.taskDescription ?? '',
        duration: task.formattedDuration,
        ep: task.estimatedPoints,
      );
    }).toList();
  }

  Widget _buildCreateTaskButton(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.4),
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

  void _showErgoCoachAndNavigate(BuildContext context, dynamic taskModel) {
    context.push(AppRouter.activeSession, extra: taskModel);
  }
}
