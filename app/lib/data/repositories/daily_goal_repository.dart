import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/errors/exceptions.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/data/models/daily_goal_model.dart';

/// Repository for daily goal operations.
class DailyGoalRepository {
  final ApiClient _apiClient;

  DailyGoalRepository(this._apiClient);

  /// Get today's daily goal progress.
  Future<Either<Failure, DailyGoalModel>> getTodayGoal() async {
    try {
      final response = await _apiClient.get(ApiConstants.dailyGoalsToday);
      return Right(
        DailyGoalModel.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data?['message'] ?? 'Failed to load',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  /// Get user's goal settings.
  Future<Either<Failure, GoalSettingsModel>> getGoalSettings() async {
    try {
      final response = await _apiClient.get(ApiConstants.dailyGoalsSettings);
      return Right(
        GoalSettingsModel.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data?['message'] ?? 'Failed to load',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  /// Update user's goal settings.
  Future<Either<Failure, GoalSettingsModel>> updateGoalSettings(
    GoalSettingsModel settings,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.dailyGoalsSettings,
        data: settings.toJson(),
      );
      return Right(
        GoalSettingsModel.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data?['message'] ?? 'Failed to save',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  /// Get daily goal history for a date range.
  Future<Either<Failure, List<DailyGoalModel>>> getGoalHistory({
    String? from,
    String? to,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (from != null) params['from'] = from;
      if (to != null) params['to'] = to;

      final response = await _apiClient.get(
        ApiConstants.dailyGoalsHistory,
        queryParameters: params,
      );
      final list = (response.data as List)
          .map((item) => DailyGoalModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data?['message'] ?? 'Failed to load',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
