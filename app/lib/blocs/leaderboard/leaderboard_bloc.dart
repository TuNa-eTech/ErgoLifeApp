import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_event.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_state.dart';
import 'package:ergo_life_app/data/models/leaderboard_model.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';

/// BLoC for managing leaderboard state
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final ActivityRepository _activityRepository;

  String? _currentWeek;
  LeaderboardScope? _currentScope;

  LeaderboardBloc({required ActivityRepository activityRepository})
    : _activityRepository = activityRepository,
      super(const LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
  }

  /// Load leaderboard data
  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    AppLogger.info('Loading leaderboard...', 'LeaderboardBloc');
    emit(const LeaderboardLoading());

    _currentWeek = event.week;
    if (event.scope != null) {
      _currentScope = event.scope;
    }

    // Default to house if not set
    final scope = _currentScope ?? LeaderboardScope.house;

    final result = await _activityRepository.getLeaderboard(
      week: event.week,
      scope: scope,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'Failed to load leaderboard',
          failure.message,
          null,
          'LeaderboardBloc',
        );

        // Try loading mock data for demo
        final mockData = _activityRepository.getMockLeaderboard(scope: scope);
        emit(
          LeaderboardLoaded(
            leaderboard: mockData,
            currentUserId: _getCurrentUserId(),
          ),
        );
      },
      (leaderboard) {
        AppLogger.success(
          'Leaderboard loaded: ${leaderboard.rankings.length} entries',
          'LeaderboardBloc',
        );
        emit(
          LeaderboardLoaded(
            leaderboard: leaderboard,
            currentUserId: _getCurrentUserId(),
          ),
        );
      },
    );
  }

  /// Refresh leaderboard (same week)
  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    AppLogger.info('Refreshing leaderboard...', 'LeaderboardBloc');
    add(LoadLeaderboard(week: _currentWeek, scope: _currentScope));
  }

  /// Get current user ID from storage
  String _getCurrentUserId() {
    // In a real app, this would come from auth state or storage
    // For now, return a placeholder
    return 'current_user_id';
  }
}
