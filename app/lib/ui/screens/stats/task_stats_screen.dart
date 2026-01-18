import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';
import 'package:ergo_life_app/core/di/service_locator.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';
import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart'; // Uncomment if using charts

class TaskStatsScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskStatsScreen({super.key, this.task});

  @override
  State<TaskStatsScreen> createState() => _TaskStatsScreenState();
}

class _TaskStatsScreenState extends State<TaskStatsScreen> {
  late final ActivityRepository _repository;
  bool _isLoading = true;
  String? _error;
  StatsModel? _stats;

  // Filter state
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth; // null = All year
  bool _isLifetime = true;

  @override
  void initState() {
    super.initState();
    _repository = sl<ActivityRepository>();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getStats(
      period: _isLifetime
          ? 'all'
          : 'month', // 'all' ignores year/month usually, but we want flexibility
      taskName: widget.task?.exerciseName,
      year: _isLifetime ? null : _selectedYear,
      month: _isLifetime ? null : _selectedMonth,
    );

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (stats) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: textColor),
        title: Text(
          widget.task?.exerciseName ?? 'Your Progress',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            _buildFilterSection(isDark),
            const SizedBox(height: 24),

            if (_error != null) _buildErrorState(isDark),
            if (_stats != null) ...[
              // Summary Cards
              _buildSummaryCards(isDark),
              const SizedBox(height: 24),

              // Streak Info (only for specific task? No, general stats have it too)
              _buildStreakCard(isDark),
              const SizedBox(height: 24),

              // If specific task: maybe history chart
              // If global: Top Tasks list
              if (widget.task == null) _buildTopTasksList(isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilterChip(
                label: Text(AppLocalizations.of(context)!.lifetime),
                selected: _isLifetime,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _isLifetime = true;
                    });
                    _loadStats();
                  }
                },
                backgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                selectedColor: AppColors.secondary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _isLifetime
                      ? AppColors.secondary
                      : (isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight),
                  fontWeight: _isLifetime ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide.none,
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: Text(
                  '$_selectedYear${_selectedMonth != null ? '/$_selectedMonth' : ''}',
                ),
                selected: !_isLifetime,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _isLifetime = false;
                    });
                    _loadStats();
                  }
                },
                backgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                selectedColor: AppColors.secondary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: !_isLifetime
                      ? AppColors.secondary
                      : (isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight),
                  fontWeight: !_isLifetime
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide.none,
              ),
            ],
          ),

          if (!_isLifetime) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                // Year Dropdown
                _buildDropdown<int>(
                  value: _selectedYear,
                  items: List.generate(
                    5,
                    (index) => DateTime.now().year - index,
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedYear = val);
                      _loadStats();
                    }
                  },
                  labelBuilder: (val) => val.toString(),
                  isDark: isDark,
                ),
                const SizedBox(width: 16),
                // Month Dropdown
                _buildDropdown<int?>(
                  value: _selectedMonth,
                  items: [null, ...List.generate(12, (index) => index + 1)],
                  onChanged: (val) {
                    setState(() => _selectedMonth = val);
                    _loadStats();
                  },
                  labelBuilder: (val) =>
                      val == null ? 'All Year' : 'Month $val',
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) labelBuilder,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder(item),
                style: TextStyle(
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
            );
          }).toList(),
          dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Total\nExecutions',
            value: '${_stats!.activityCount}',
            icon: Icons.repeat_rounded,
            color: Colors.blue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Total\nTime',
            value: _stats!.formattedDuration,
            icon: Icons.timer_rounded,
            color: Colors.purple,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Calories\nBurned',
            value: '${_stats!.estimatedCalories}',
            icon: Icons.local_fire_department_rounded,
            color: Colors.orange,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              color: color.withOpacity(0.1),
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

  Widget _buildStreakCard(bool isDark) {
    if (_stats == null) return const SizedBox.shrink();

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
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
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
                  '${_stats!.streakDays} Days',
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
                _stats!.formattedPoints,
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

  Widget _buildTopTasksList(bool isDark) {
    if (_stats?.topTasks.isEmpty ?? true) return const SizedBox.shrink();

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
        ..._stats!.topTasks.map(
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
                    color: (isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100),
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

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
            const SizedBox(height: 12),
            Text(
              _error ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
