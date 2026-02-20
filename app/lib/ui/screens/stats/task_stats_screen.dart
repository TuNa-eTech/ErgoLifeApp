import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';
import 'package:ergo_life_app/core/di/service_locator.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/blocs/stats/stats_bloc.dart';
import 'package:ergo_life_app/blocs/stats/stats_event.dart';
import 'package:ergo_life_app/blocs/stats/stats_state.dart';
import 'package:ergo_life_app/ui/widgets/charts/weekly_bar_chart.dart';
import 'package:ergo_life_app/ui/widgets/charts/category_donut_chart.dart';
import 'package:ergo_life_app/ui/widgets/charts/activity_heatmap.dart';
import 'package:ergo_life_app/ui/widgets/charts/streak_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen displaying activity statistics with charts.
///
/// Uses [StatsBloc] to load aggregate stats, daily
/// breakdown, and heatmap data in parallel.
class TaskStatsScreen extends StatelessWidget {
  final TaskModel? task;

  const TaskStatsScreen({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StatsBloc(sl<ActivityRepository>(), taskName: task?.exerciseName)
            ..add(const LoadStats()),
      child: _TaskStatsView(task: task),
    );
  }
}

class _TaskStatsView extends StatelessWidget {
  final TaskModel? task;
  const _TaskStatsView({this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: textColor),
          title: Text(
            task?.exerciseName ?? 'Your Progress',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.secondary,
            labelColor: AppColors.secondary,
            unselectedLabelColor: isDark
                ? AppColors.textSubDark
                : AppColors.textSubLight,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Charts'),
              Tab(text: 'Heatmap'),
            ],
          ),
        ),
        body: BlocBuilder<StatsBloc, StatsState>(
          builder: (context, state) {
            if (state is StatsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StatsError) {
              return _ErrorView(message: state.message, isDark: isDark);
            }
            if (state is StatsLoaded) {
              return TabBarView(
                children: [
                  _OverviewTab(stats: state.stats, isDark: isDark),
                  _ChartsTab(state: state, isDark: isDark),
                  _HeatmapTab(state: state, isDark: isDark),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ===== Overview Tab =====

class _OverviewTab extends StatelessWidget {
  final StatsModel stats;
  final bool isDark;

  const _OverviewTab({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryCards(stats: stats, isDark: isDark),
          const SizedBox(height: 24),
          _StreakCard(stats: stats, isDark: isDark),
          const SizedBox(height: 24),
          if (stats.topTasks.isNotEmpty)
            _TopTasksList(topTasks: stats.topTasks, isDark: isDark),
        ],
      ),
    );
  }
}

// ===== Charts Tab =====

class _ChartsTab extends StatelessWidget {
  final StatsLoaded state;
  final bool isDark;

  const _ChartsTab({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          WeeklyBarChart(data: state.dailyBreakdown, isDark: isDark),
          const SizedBox(height: 20),
          CategoryDonutChart(topTasks: state.stats.topTasks, isDark: isDark),
        ],
      ),
    );
  }
}

// ===== Heatmap Tab =====

class _HeatmapTab extends StatelessWidget {
  final StatsLoaded state;
  final bool isDark;

  const _HeatmapTab({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ActivityHeatmap(data: state.heatmapData, isDark: isDark),
          const SizedBox(height: 20),
          StreakCalendar(data: state.heatmapData, isDark: isDark),
        ],
      ),
    );
  }
}

// ===== Shared Widgets =====

class _SummaryCards extends StatelessWidget {
  final StatsModel stats;
  final bool isDark;

  const _SummaryCards({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total\nExecutions',
            value: '${stats.activityCount}',
            icon: Icons.repeat_rounded,
            color: Colors.blue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Total\nTime',
            value: stats.formattedDuration,
            icon: Icons.timer_rounded,
            color: Colors.purple,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Calories\nBurned',
            value: '${stats.estimatedCalories}',
            icon: Icons.local_fire_department_rounded,
            color: Colors.orange,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 1.2,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final StatsModel stats;
  final bool isDark;

  const _StreakCard({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C1F16), const Color(0xFF38251B)]
              : [const Color(0xFFFFF0E6), const Color(0xFFFFF7F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Streak',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.orange.shade200
                        : Colors.orange.shade800,
                  ),
                ),
                Text(
                  '${stats.streakDays} Days',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Totals',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
              ),
              Text(
                stats.formattedPoints,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Points',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopTasksList extends StatelessWidget {
  final List<TopTask> topTasks;
  final bool isDark;

  const _TopTasksList({required this.topTasks, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Tasks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 16),
        ...topTasks.map(
          (task) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${task.count}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        'times',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textSubDark
                              : AppColors.textSubLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.taskName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.formattedDuration,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSubDark
                              : AppColors.textSubLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${task.totalPoints}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      'pts',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSubDark
                            : AppColors.textSubLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;

  const _ErrorView({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<StatsBloc>().add(const LoadStats());
              },
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
