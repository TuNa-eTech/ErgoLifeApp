import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/home/home_event.dart';
import 'package:ergo_life_app/blocs/home/home_state.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/data/repositories/auth_repository.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';
import 'package:ergo_life_app/data/repositories/house_repository.dart';

/// BLoC for managing home screen state
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthRepository _authRepository;
  final ActivityRepository _activityRepository;
  final HouseRepository _houseRepository;

  HomeBloc({
    required AuthRepository authRepository,
    required ActivityRepository activityRepository,
    required HouseRepository houseRepository,
  })  : _authRepository = authRepository,
        _activityRepository = activityRepository,
        _houseRepository = houseRepository,
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
          AppLogger.error('Failed to load user', failure.message, null, 'HomeBloc');
          emit(HomeError(message: failure.message));
        },
        (user) async {
          // Fetch stats (with fallback to mock)
          WeeklyStats stats;
          final statsResult = await _activityRepository.getStats(period: 'week');
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

          // Get quick tasks (predefined for now)
          final quickTasks = PredefinedTasks.quickTasks;

          AppLogger.success('Home data loaded', 'HomeBloc');
          emit(HomeLoaded(
            user: user,
            stats: stats,
            house: house,
            quickTasks: quickTasks,
          ));
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
}
