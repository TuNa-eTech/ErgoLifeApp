import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_event.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_state.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/activity_model.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';
import 'package:ergo_life_app/data/repositories/task_repository.dart';

import 'package:ergo_life_app/data/models/user_model.dart';
import 'package:ergo_life_app/data/repositories/user_repository.dart';

/// BLoC for managing tasks screen state
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final ActivityRepository _activityRepository;
  final TaskRepository _taskRepository;
  final UserRepository _userRepository;

  TasksBloc({
    required ActivityRepository activityRepository,
    required TaskRepository taskRepository,
    required UserRepository userRepository,
  }) : _activityRepository = activityRepository,
       _taskRepository = taskRepository,
       _userRepository = userRepository,
       super(const TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<RefreshTasks>(_onRefreshTasks);
    on<FilterTasks>(_onFilterTasks);
  }

  Future<UserModel?> _safeFetchUser() async {
    try {
      return await _userRepository.fetchUser();
    } catch (e) {
      // Try cache
      return _userRepository.getCachedUser();
    }
  }

  /// Load all tasks and activities from API
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    AppLogger.info('Loading tasks data...', 'TasksBloc');
    if (!event.silent) {
      emit(const TasksLoading());
    }

    try {
      // 1. Check if user needs task seeding
      final needsSeedingResult = await _taskRepository.needsTaskSeeding();
      if (needsSeedingResult.fold((_) => false, (v) => v)) {
        AppLogger.info('Seeding default tasks...', 'TasksBloc');
        await _seedTasksFromTemplates();
      }

      // 2. Fetch all required data in parallel
      final results = await Future.wait<dynamic>([
        _taskRepository.getTasks(), // [0] Tasks
        _activityRepository.getActivities(page: 1, limit: 10), // [1] Activities
        _safeFetchUser(), // [2] User Profile (Nullable)
        _activityRepository.getStats(period: 'day'), // [3] Daily Stats
        _activityRepository.getStats(period: 'all'), // [4] Lifetime Stats
      ]);

      // 3. Process Tasks
      final tasksResult = results[0] as dynamic; // Either<Failure, List<Map>>
      final tasks =
          tasksResult.fold(
                (failure) {
                  AppLogger.error(
                    'Failed to load tasks',
                    failure.toString(),
                    null,
                    'TasksBloc',
                  );
                  return <TaskModel>[];
                },
                (taskMaps) => (taskMaps as List)
                    .map((json) => TaskModel.fromJson(json))
                    .toList(),
              )
              as List<TaskModel>;

      final highPriority = tasks.where((t) => t.isFavorite).toList();
      final availableTasks = tasks.where((t) => !t.isHidden).toList();

      // 4. Process Activities
      final activitiesResult =
          results[1] as dynamic; // Either<Failure, PaginatedActivities>
      final recentActivities =
          activitiesResult.fold(
                (_) => <ActivityModel>[],
                (paginated) =>
                    (paginated.activities as List).cast<ActivityModel>(),
              )
              as List<ActivityModel>;

      // 5. Process User & Stats
      final user = results[2] as UserModel?;
      final dailyStatsResult = results[3] as dynamic;
      final lifetimeStatsResult = results[4] as dynamic;

      int currentStreak = user?.currentStreak ?? 0;
      int walletBalance = user?.walletBalance ?? 0;

      // Active Tab Stats (Daily)
      int completedToday = 0;
      int focusMinutesToday = 0;

      dailyStatsResult.fold(
        (failure) {
          // Fallback to client-side calc
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          completedToday = recentActivities.where((a) {
            final d = DateTime.parse(a.completedAt.toString());
            return DateTime(d.year, d.month, d.day) == today;
          }).length;
        },
        (stats) {
          completedToday = stats.activityCount;
          focusMinutesToday = stats.totalDurationMinutes;
        },
      );

      // Completed Tab Stats (Lifetime)
      int totalCompleted = 0;
      int totalMinutes = 0;

      lifetimeStatsResult.fold(
        (failure) {
          // Fallback
          totalCompleted = recentActivities.length;
          totalMinutes = recentActivities.fold(
            0,
            (sum, a) => sum + a.durationMinutes,
          );
        },
        (stats) {
          totalCompleted = stats.activityCount;
          totalMinutes = stats.totalDurationMinutes;
        },
      );

      // Use walletBalance for Total EP
      final totalEPEarned = walletBalance;

      AppLogger.success('Tasks data loaded', 'TasksBloc');
      emit(
        TasksLoaded(
          highPriorityTask: highPriority.isNotEmpty ? highPriority.first : null,
          availableTasks: availableTasks,
          recentActivities: recentActivities,
          completedToday: completedToday,
          totalTasks: availableTasks.length,
          focusMinutesToday: focusMinutesToday, // From Daily Stats API
          currentStreak: currentStreak, // From User API
          totalCompleted: totalCompleted, // From Lifetime Stats API
          totalEPEarned: totalEPEarned, // From User Wallet
          totalMinutes: totalMinutes, // From Lifetime Stats API
          hasMoreActivities: false, // TODO: Implement pagination check
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to load tasks data', e, null, 'TasksBloc');
      emit(const TasksError(message: 'Failed to load data'));
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
    add(const LoadTasks(silent: true));
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
