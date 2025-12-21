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
  final String currentFilter; // 'active', 'completed', 'saved'

  const TasksLoaded({
    this.highPriorityTask,
    required this.availableTasks,
    required this.recentActivities,
    this.currentFilter = 'active',
  });

  /// Get filtered tasks based on current filter
  List<dynamic> get filteredItems {
    switch (currentFilter) {
      case 'completed':
        return recentActivities;
      case 'saved':
        return []; // Future: saved routines
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
  }) {
    return TasksLoaded(
      highPriorityTask: highPriorityTask ?? this.highPriorityTask,
      availableTasks: availableTasks ?? this.availableTasks,
      recentActivities: recentActivities ?? this.recentActivities,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  @override
  List<Object?> get props => [
        highPriorityTask,
        availableTasks,
        recentActivities,
        currentFilter,
      ];
}

/// Error state
class TasksError extends TasksState {
  final String message;

  const TasksError({required this.message});

  @override
  List<Object?> get props => [message];
}
