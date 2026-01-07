import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/home/home_event.dart';
import 'package:ergo_life_app/blocs/home/home_state.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/data/repositories/auth_repository.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';
import 'package:ergo_life_app/data/repositories/house_repository.dart';
import 'package:ergo_life_app/data/repositories/task_repository.dart';

/// BLoC for managing home screen state
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthRepository _authRepository;
  final ActivityRepository _activityRepository;
  final HouseRepository _houseRepository;
  final TaskRepository _taskRepository;

  HomeBloc({
    required AuthRepository authRepository,
    required ActivityRepository activityRepository,
    required HouseRepository houseRepository,
    required TaskRepository taskRepository,
  }) : _authRepository = authRepository,
       _activityRepository = activityRepository,
       _houseRepository = houseRepository,
       _taskRepository = taskRepository,
       super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  /// Load all home screen data
  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    AppLogger.info('Loading home data...', 'HomeBloc');
    emit(const HomeLoading());

    try {
      // Fetch user data
      final userResult = await _authRepository.getCurrentUser();

      await userResult.fold(
        (failure) async {
          AppLogger.error(
            'Failed to load user',
            failure.message,
            null,
            'HomeBloc',
          );
          emit(HomeError(message: failure.message));
        },
        (user) async {
          // Fetch stats (with fallback to mock)
          WeeklyStats stats;
          final statsResult = await _activityRepository.getStats(
            period: 'week',
          );
          stats = statsResult.fold(
            (_) => WeeklyStats.empty(),
            (s) => WeeklyStats(
              totalPoints: s.totalPoints,
              activityCount: s.activityCount,
              totalDurationMinutes: s.totalDurationMinutes,
              streakDays: s.streakDays,
              rankPosition: 0,
              houseMemberCount: 1,
            ),
          );

          // Fetch house (optional)
          final houseResult = await _houseRepository.getMyHouse();
          final house = houseResult.fold((_) => null, (h) => h);

          // Check and seed tasks for new users
          await _ensureTasksSeeded();

          // Fetch quick tasks from API
          final tasksResult = await _taskRepository.getTasks();
          final quickTasks = tasksResult.fold(
            (_) => <TaskModel>[],
            (taskMaps) => taskMaps
                .where((json) => json['isHidden'] != true)
                .take(5) // Limit to 5 quick tasks for home screen
                .map((json) => TaskModel.fromJson(json))
                .toList(),
          );

          AppLogger.success(
            'Home data loaded with ${quickTasks.length} tasks',
            'HomeBloc',
          );
          emit(
            HomeLoaded(
              user: user,
              stats: stats,
              house: house,
              quickTasks: quickTasks,
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error loading home', e, null, 'HomeBloc');
      emit(const HomeError(message: 'Failed to load home data'));
    }
  }

  /// Refresh home data (same as load but for pull-to-refresh)
  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    AppLogger.info('Refreshing home data...', 'HomeBloc');
    // Keep current state while refreshing
    add(const LoadHomeData());
  }

  /// Load with mock data for offline/demo mode
  void loadMockData() {
    AppLogger.info('Loading mock home data...', 'HomeBloc');
    // This can be called when network fails to show demo data
  }

  /// Ensure tasks are seeded for new users
  Future<void> _ensureTasksSeeded() async {
    try {
      AppLogger.info('Checking if user needs task seeding...', 'HomeBloc');

      // Check if user needs seeding
      final needsSeedingResult = await _taskRepository.needsTaskSeeding();

      // Log the raw result for debugging
      needsSeedingResult.fold(
        (failure) => AppLogger.error(
          'needsTaskSeeding returned failure: ${failure.message}',
          null,
          null,
          'HomeBloc',
        ),
        (value) =>
            AppLogger.info('needsTaskSeeding returned: $value', 'HomeBloc'),
      );

      final needsSeeding = needsSeedingResult.fold(
        (_) => false,
        (value) => value,
      );

      if (!needsSeeding) {
        AppLogger.info(
          'User already has tasks (needsSeeding=$needsSeeding), skipping seeding',
          'HomeBloc',
        );
        return;
      }

      AppLogger.info('New user detected, seeding default tasks...', 'HomeBloc');

      // Get task templates
      final templatesResult = await _taskRepository.getTaskTemplates();
      final templates = templatesResult.fold((failure) {
        AppLogger.error(
          'Failed to fetch templates',
          failure.message,
          null,
          'HomeBloc',
        );
        return <Map<String, dynamic>>[];
      }, (value) => value);

      if (templates.isEmpty) {
        AppLogger.warning('No templates available for seeding', 'HomeBloc');
        return;
      }

      AppLogger.info(
        'Got ${templates.length} templates, seeding...',
        'HomeBloc',
      );

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
          'HomeBloc',
        ),
        (data) => AppLogger.success(
          'Tasks seeded successfully: ${data['tasksCreated']} tasks',
          'HomeBloc',
        ),
      );
    } catch (e) {
      AppLogger.error('Error during task seeding', e, null, 'HomeBloc');
    }
  }
}
