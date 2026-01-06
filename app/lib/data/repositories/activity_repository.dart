import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/errors/exceptions.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/activity_model.dart';
import 'package:ergo_life_app/data/models/leaderboard_model.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';

/// Repository for activity-related operations
class ActivityRepository {
  final ApiClient _apiClient;

  ActivityRepository(this._apiClient);

  /// Create a new activity after completing a task
  Future<Either<Failure, CreateActivityResponse>> createActivity({
    required String taskName,
    required int durationSeconds,
    required double metsValue,
    required int magicWipePercentage,
  }) async {
    try {
      AppLogger.info('Creating activity: $taskName', 'ActivityRepository');

      final response = await _apiClient.post(
        ApiConstants.activities,
        data: {
          'taskName': taskName,
          'durationSeconds': durationSeconds,
          'metsValue': metsValue,
          'magicWipePercentage': magicWipePercentage,
        },
      );

      // Backend wraps response in {success: bool, data: {...}}
      final actualData = _apiClient.unwrapResponse(response.data);
      final activityResponse = CreateActivityResponse.fromJson(
        actualData as Map<String, dynamic>,
      );

      AppLogger.success(
        'Activity created. Points earned: ${activityResponse.wallet.pointsEarned}',
        'ActivityRepository',
      );

      return Right(activityResponse);
    } on ServerException catch (e) {
      AppLogger.error('Create activity failed', e.message, null, 'ActivityRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'ActivityRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } on DioException catch (e) {
      // Extract error message from backend response
      String errorMessage = 'Create activity failed';

      if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData['message'] != null) {
            final message = responseData['message'];
            if (message is List) {
              errorMessage = message.join(', ');
            } else {
              errorMessage = message.toString();
            }
          } else if (responseData['error'] != null) {
            errorMessage = responseData['error'].toString();
          }
        }
      }

      AppLogger.error('Create activity failed', errorMessage, null, 'ActivityRepository');
      return Left(ServerFailure(message: errorMessage));
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

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final response = await _apiClient.get(
        ApiConstants.activities,
        queryParameters: queryParams,
      );

      final paginatedActivities = PaginatedActivities.fromJson(
        response.data as Map<String, dynamic>,
      );

      AppLogger.success(
        'Loaded ${paginatedActivities.activities.length} activities',
        'ActivityRepository',
      );

      return Right(paginatedActivities);
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

      final queryParams = <String, dynamic>{};
      if (week != null) queryParams['week'] = week;

      final response = await _apiClient.get(
        ApiConstants.activitiesLeaderboard,
        queryParameters: queryParams,
      );

      // Backend wraps response in {success: bool, data: {...}}
      final actualData = _apiClient.unwrapResponse(response.data);
      final leaderboard = LeaderboardResponse.fromJson(
        actualData as Map<String, dynamic>,
      );

      AppLogger.success(
        'Loaded leaderboard with ${leaderboard.rankings.length} entries',
        'ActivityRepository',
      );

      return Right(leaderboard);
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

      final response = await _apiClient.get(
        ApiConstants.activitiesStats,
        queryParameters: {'period': period},
      );

      // Backend wraps response in {success: bool, data: {...}}
      final actualData = _apiClient.unwrapResponse(response.data);
      final stats = StatsModel.fromJson(actualData as Map<String, dynamic>);

      AppLogger.success('Loaded stats', 'ActivityRepository');

      return Right(stats);
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
  LeaderboardResponse getMockLeaderboard({
    LeaderboardScope scope = LeaderboardScope.house,
  }) {
    return LeaderboardResponse(
      scope: scope,
      week: '2025-W51',
      weekStart: DateTime(2025, 12, 16),
      weekEnd: DateTime(2025, 12, 22),
      houseName: scope == LeaderboardScope.house ? 'My House' : null,
      rankings: _mockRankings,
      myRanking: null,
      totalParticipants: _mockRankings.length,
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
