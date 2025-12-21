import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_event.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_state.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/activity_model.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';

/// BLoC for managing tasks screen state
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final ActivityRepository _activityRepository;

  TasksBloc({
    required ActivityRepository activityRepository,
  })  : _activityRepository = activityRepository,
        super(const TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<RefreshTasks>(_onRefreshTasks);
    on<FilterTasks>(_onFilterTasks);
  }

  /// Load all tasks and activities
  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TasksState> emit,
  ) async {
    AppLogger.info('Loading tasks...', 'TasksBloc');
    emit(const TasksLoading());

    try {
      // Get high priority task
      final highPriority = PredefinedTasks.getHighPriorityTask();

      // Get available tasks
      final availableTasks = PredefinedTasks.getNormalTasks();

      // Get recent activities
      final activitiesResult = await _activityRepository.getActivities(
        page: 1,
        limit: 10,
      );

      final recentActivities = activitiesResult.fold(
        (_) => <ActivityModel>[],
        (paginated) => paginated.activities.cast<ActivityModel>(),
      );

      AppLogger.success('Tasks loaded', 'TasksBloc');
      emit(TasksLoaded(
        highPriorityTask: highPriority,
        availableTasks: availableTasks,
        recentActivities: recentActivities,
      ));
    } catch (e) {
      AppLogger.error('Failed to load tasks', e, null, 'TasksBloc');
      emit(const TasksError(message: 'Failed to load tasks'));
    }
  }

  /// Refresh tasks
  Future<void> _onRefreshTasks(
    RefreshTasks event,
    Emitter<TasksState> emit,
  ) async {
    AppLogger.info('Refreshing tasks...', 'TasksBloc');
    add(const LoadTasks());
  }

  /// Filter tasks by category
  void _onFilterTasks(
    FilterTasks event,
    Emitter<TasksState> emit,
  ) {
    final currentState = state;
    if (currentState is TasksLoaded) {
      AppLogger.info('Filtering tasks: ${event.filter}', 'TasksBloc');
      emit(currentState.copyWith(currentFilter: event.filter));
    }
  }
}
