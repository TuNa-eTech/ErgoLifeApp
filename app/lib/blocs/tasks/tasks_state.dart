import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/data/models/activity_model.dart';

/// TasksBloc states
abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TasksInitial extends TasksState {
  const TasksInitial();
}

/// Loading state
class TasksLoading extends TasksState {
  const TasksLoading();
}

/// Successfully loaded tasks
class TasksLoaded extends TasksState {
  final TaskModel? highPriorityTask;
  final List<TaskModel> availableTasks;
  final List<ActivityModel> recentActivities;
  final String currentFilter; // 'active', 'completed'

  // Stats for Active filter
  final int completedToday;
  final int totalTasks;
  final int focusMinutesToday;
  final int currentStreak;

  // Stats for Completed filter
  final int totalCompleted;
  final int totalEPEarned;
  final int totalMinutes;

  // Pagination
  final bool hasMoreActivities;

  const TasksLoaded({
    this.highPriorityTask,
    required this.availableTasks,
    required this.recentActivities,
    this.currentFilter = 'active',
    this.completedToday = 0,
    this.totalTasks = 0,
    this.focusMinutesToday = 0,
    this.currentStreak = 0,
    this.totalCompleted = 0,
    this.totalEPEarned = 0,
    this.totalMinutes = 0,
    this.hasMoreActivities = false,
  });

  /// Get filtered tasks based on current filter
  List<dynamic> get filteredItems {
    switch (currentFilter) {
      case 'completed':
        return recentActivities;
      case 'active':
      default:
        return availableTasks;
    }
  }

  /// Check if filter is active
  bool isFilterActive(String filter) => currentFilter == filter;

  TasksLoaded copyWith({
    TaskModel? highPriorityTask,
    List<TaskModel>? availableTasks,
    List<ActivityModel>? recentActivities,
    String? currentFilter,
    int? completedToday,
    int? totalTasks,
    int? focusMinutesToday,
    int? currentStreak,
    int? totalCompleted,
    int? totalEPEarned,
    int? totalMinutes,
    bool? hasMoreActivities,
  }) {
    return TasksLoaded(
      highPriorityTask: highPriorityTask ?? this.highPriorityTask,
      availableTasks: availableTasks ?? this.availableTasks,
      recentActivities: recentActivities ?? this.recentActivities,
      currentFilter: currentFilter ?? this.currentFilter,
      completedToday: completedToday ?? this.completedToday,
      totalTasks: totalTasks ?? this.totalTasks,
      focusMinutesToday: focusMinutesToday ?? this.focusMinutesToday,
      currentStreak: currentStreak ?? this.currentStreak,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalEPEarned: totalEPEarned ?? this.totalEPEarned,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      hasMoreActivities: hasMoreActivities ?? this.hasMoreActivities,
    );
  }

  @override
  List<Object?> get props => [
    highPriorityTask,
    availableTasks,
    recentActivities,
    currentFilter,
    completedToday,
    totalTasks,
    focusMinutesToday,
    currentStreak,
    totalCompleted,
    totalEPEarned,
    totalMinutes,
    hasMoreActivities,
  ];
}

/// Error state
class TasksError extends TasksState {
  final String message;

  const TasksError({required this.message});

  @override
  List<Object?> get props => [message];
}
