import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/home/home_bloc.dart';
import 'package:ergo_life_app/blocs/home/home_event.dart';
import 'package:ergo_life_app/blocs/home/home_state.dart';
import 'package:ergo_life_app/ui/screens/home/widgets/home_header.dart';
import 'package:ergo_life_app/ui/screens/home/widgets/compact_stats_bar.dart'; // [NEW]
import 'package:ergo_life_app/ui/screens/home/widgets/quick_tasks_section.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:ergo_life_app/core/utils/talker_config.dart';
// Removed: ArenaSection, PersonalStatsSection, HouseActionsRow, StreakBadge...

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
                    context.push(AppRouter.createTask);
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

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
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
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const RefreshHomeData());
        // Wait for the refresh to complete
        await Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Sticky Header
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            surfaceTintColor: isDark ? AppColors.surfaceDark : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 4,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: HomeHeader(
              isDark: isDark,
              userName: state.firstName,
              onNotificationTap: () {
                // TODO: Handle notification tap
              },
              onAvatarLongPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        TalkerScreen(talker: TalkerConfig.talker),
                  ),
                );
              },
            ),
          ),

          // Scrollable Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // New Compact Stats Bar
                CompactStatsBar(
                  isDark: isDark,
                  stats: state.stats,
                  currentStreak: state.user.currentStreak,
                ),

                const SizedBox(height: 16),

                // Existing Quick Tasks Grid
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
                  onTasksChanged: () {
                    // Reload home data when tasks are modified
                    context.read<HomeBloc>().add(const RefreshHomeData());
                  },
                ),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ],
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

  void _showErgoCoachAndNavigate(BuildContext context, dynamic taskModel) {
    context.push(AppRouter.activeSession, extra: taskModel);
  }
}
