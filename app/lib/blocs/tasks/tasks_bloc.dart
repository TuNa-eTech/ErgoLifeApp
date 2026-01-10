import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_event.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_state.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/activity_model.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';
import 'package:ergo_life_app/data/repositories/task_repository.dart';

/// BLoC for managing tasks screen state
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final ActivityRepository _activityRepository;
  final TaskRepository _taskRepository;

  TasksBloc({
    required ActivityRepository activityRepository,
    required TaskRepository taskRepository,
  }) : _activityRepository = activityRepository,
       _taskRepository = taskRepository,
       super(const TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<RefreshTasks>(_onRefreshTasks);
    on<FilterTasks>(_onFilterTasks);
  }

  /// Load all tasks and activities from API
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    AppLogger.info('Loading tasks from API...', 'TasksBloc');
    emit(const TasksLoading());

    try {
      // Check if user needs task seeding (first time user)
      final needsSeedingResult = await _taskRepository.needsTaskSeeding();
      final needsSeeding = needsSeedingResult.fold(
        (_) => false,
        (value) => value,
      );

      if (needsSeeding) {
        AppLogger.info(
          'User needs task seeding, fetching templates...',
          'TasksBloc',
        );
        await _seedTasksFromTemplates();
      }

      // Fetch tasks from API
      final tasksResult = await _taskRepository.getTasks();
      final tasks = tasksResult.fold(
        (failure) {
          AppLogger.error(
            'Failed to load tasks from API',
            failure.message,
            null,
            'TasksBloc',
          );
          return <TaskModel>[];
        },
        (taskMaps) => taskMaps.map((json) => TaskModel.fromJson(json)).toList(),
      );

      // Separate high priority and normal tasks
      final highPriority = tasks.where((t) => t.isFavorite).toList();
      final availableTasks = tasks.where((t) => !t.isHidden).toList();

      // Get recent activities
      final activitiesResult = await _activityRepository.getActivities(
        page: 1,
        limit: 10,
      );

      final recentActivities = activitiesResult.fold(
        (_) => <ActivityModel>[],
        (paginated) => paginated.activities.cast<ActivityModel>(),
      );

      AppLogger.success('Loaded ${tasks.length} tasks from API', 'TasksBloc');
      emit(
        TasksLoaded(
          highPriorityTask: highPriority.isNotEmpty ? highPriority.first : null,
          availableTasks: availableTasks,
          recentActivities: recentActivities,
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to load tasks', e, null, 'TasksBloc');
      emit(const TasksError(message: 'Failed to load tasks'));
    }
  }

  /// Seed tasks from templates for new users
  Future<void> _seedTasksFromTemplates() async {
    try {
      // Get task templates
      final templatesResult = await _taskRepository.getTaskTemplates();
      final templates = templatesResult.fold(
        (_) => <Map<String, dynamic>>[],
        (value) => value,
      );

      if (templates.isEmpty) {
        AppLogger.warning('No templates available for seeding', 'TasksBloc');
        return;
      }

      // Convert templates to seed format
      final tasksToSeed = templates.map((template) {
        return {
          'exerciseName': template['name'] ?? template['exerciseName'],
          'taskDescription':
              template['description'] ?? template['taskDescription'],
          'durationMinutes':
              template['defaultDuration'] ?? template['durationMinutes'] ?? 15,
          'metsValue': template['metsValue'] ?? 3.5,
          'icon': template['icon'] ?? 'fitness_center',
          'animation': template['animation'],
          'color': template['color'] ?? '#FF6A00',
          'templateId': template['id'],
        };
      }).toList();

      // Seed tasks
      final seedResult = await _taskRepository.seedTasks(tasksToSeed);
      seedResult.fold(
        (failure) => AppLogger.error(
          'Failed to seed tasks',
          failure.message,
          null,
          'TasksBloc',
        ),
        (_) => AppLogger.success('Tasks seeded successfully', 'TasksBloc'),
      );
    } catch (e) {
      AppLogger.error('Error seeding tasks', e, null, 'TasksBloc');
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
  void _onFilterTasks(FilterTasks event, Emitter<TasksState> emit) {
    final currentState = state;
    if (currentState is TasksLoaded) {
      AppLogger.info('Filtering tasks: ${event.filter}', 'TasksBloc');
      emit(currentState.copyWith(currentFilter: event.filter));
    }
  }
}
