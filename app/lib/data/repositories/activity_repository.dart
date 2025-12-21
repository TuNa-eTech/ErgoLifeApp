import 'package:dartz/dartz.dart';
import 'package:ergo_life_app/core/errors/exceptions.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/activity_model.dart';
import 'package:ergo_life_app/data/models/leaderboard_model.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/data/services/api_service.dart';

/// Repository for activity-related operations
class ActivityRepository {
  final ApiService _apiService;

  ActivityRepository(this._apiService);

  /// Create a new activity after completing a task
  Future<Either<Failure, CreateActivityResponse>> createActivity({
    required String taskName,
    required int durationSeconds,
    required double metsValue,
    required int magicWipePercentage,
  }) async {
    try {
      AppLogger.info('Creating activity: $taskName', 'ActivityRepository');

      final response = await _apiService.createActivity(
        taskName: taskName,
        durationSeconds: durationSeconds,
        metsValue: metsValue,
        magicWipePercentage: magicWipePercentage,
      );

      AppLogger.success(
        'Activity created. Points earned: ${response.wallet.pointsEarned}',
        'ActivityRepository',
      );

      return Right(response);
    } on ServerException catch (e) {
      AppLogger.error('Create activity failed', e.message, null, 'ActivityRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'ActivityRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Unexpected error', e, null, 'ActivityRepository');
      return Left(ServerFailure(message: 'Failed to create activity'));
    }
  }

  /// Get activity history with pagination
  Future<Either<Failure, PaginatedActivities>> getActivities({
    int page = 1,
    int limit = 20,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      AppLogger.info('Fetching activities page $page', 'ActivityRepository');

      final response = await _apiService.getActivities(
        page: page,
        limit: limit,
        fromDate: fromDate,
        toDate: toDate,
      );

      AppLogger.success(
        'Loaded ${response.activities.length} activities',
        'ActivityRepository',
      );

      return Right(response);
    } on ServerException catch (e) {
      AppLogger.error('Get activities failed', e.message, null, 'ActivityRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'ActivityRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Unexpected error', e, null, 'ActivityRepository');
      return Left(ServerFailure(message: 'Failed to load activities'));
    }
  }

  /// Get leaderboard for a specific week
  Future<Either<Failure, LeaderboardResponse>> getLeaderboard({
    String? week,
  }) async {
    try {
      AppLogger.info('Fetching leaderboard', 'ActivityRepository');

      final response = await _apiService.getLeaderboard(week: week);

      AppLogger.success(
        'Loaded leaderboard with ${response.rankings.length} entries',
        'ActivityRepository',
      );

      return Right(response);
    } on ServerException catch (e) {
      AppLogger.error('Get leaderboard failed', e.message, null, 'ActivityRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'ActivityRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Unexpected error', e, null, 'ActivityRepository');
      return Left(ServerFailure(message: 'Failed to load leaderboard'));
    }
  }

  /// Get activity stats for a period
  Future<Either<Failure, StatsModel>> getStats({
    String period = 'week',
  }) async {
    try {
      AppLogger.info('Fetching stats for period: $period', 'ActivityRepository');

      final response = await _apiService.getStats(period: period);

      AppLogger.success('Loaded stats', 'ActivityRepository');

      return Right(response);
    } on ServerException catch (e) {
      AppLogger.error('Get stats failed', e.message, null, 'ActivityRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'ActivityRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Unexpected error', e, null, 'ActivityRepository');
      return Left(ServerFailure(message: 'Failed to load stats'));
    }
  }

  // ===== Mock Methods for Offline/Demo Mode =====

  /// Get mock leaderboard for demo
  LeaderboardResponse getMockLeaderboard() {
    return LeaderboardResponse(
      week: '2025-W51',
      weekStart: DateTime(2025, 12, 16),
      weekEnd: DateTime(2025, 12, 22),
      rankings: _mockRankings,
    );
  }

  /// Get mock stats for demo
  StatsModel getMockStats({String period = 'week'}) {
    return StatsModel(
      period: period,
      totalPoints: 1240,
      activityCount: 8,
      totalDurationMinutes: 180,
      streakDays: 5,
      averagePointsPerActivity: 155,
    );
  }

  // Mock data
  static final List<LeaderboardEntry> _mockRankings = [];
}
