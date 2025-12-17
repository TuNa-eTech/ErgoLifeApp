import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/ui/screens/home/widgets/home_header.dart';
import 'package:ergo_life_app/ui/screens/home/widgets/arena_section.dart';
import 'package:ergo_life_app/ui/screens/home/widgets/quick_tasks_section.dart';

/// Home screen displaying user dashboard with arena and quick tasks
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                isDark: isDark,
                userName: 'Minh',
                onNotificationTap: () {
                  // TODO: Handle notification tap
                },
              ),
              ArenaSection(
                isDark: isDark,
                userPoints: 1240,
                rivalPoints: 1100,
                totalPoints: 1600,
                onLeaderboardTap: () {
                  // TODO: Navigate to leaderboard
                },
              ),
              QuickTasksSection(
                isDark: isDark,
                tasks: _getQuickTasks(),
                onTaskTap: (task) {
                  context.push(AppRouter.activeSession);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildCreateTaskButton(context),
    );
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

  /// Returns hardcoded quick tasks data
  /// TODO: Replace with actual data from state management
  List<TaskData> _getQuickTasks() {
    return const [
      TaskData(
        icon: Icons.cleaning_services,
        iconColor: Colors.purple,
        title: 'Legs & Glutes',
        subtitle: 'Vacuuming the Living Room',
        duration: '20 min',
        ep: 150,
      ),
      TaskData(
        icon: Icons.local_laundry_service,
        iconColor: Colors.blue,
        title: 'Upper Body Press',
        subtitle: 'Laundry Loading',
        duration: '15 min',
        ep: 80,
      ),
      TaskData(
        icon: Icons.shopping_bag,
        iconColor: Colors.green,
        title: 'Cardio Dash',
        subtitle: 'Grocery Run',
        duration: '45 min',
        ep: 200,
      ),
      TaskData(
        icon: Icons.water_drop,
        iconColor: Colors.pink,
        title: 'Core Stability',
        subtitle: 'Dishwashing',
        duration: '10 min',
        ep: 50,
      ),
    ];
  }
}
