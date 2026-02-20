import 'package:dartz/dartz.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/data/models/badge_model.dart';

/// Repository for achievement-related API calls.
class AchievementRepository {
  final ApiClient _apiClient;

  AchievementRepository(this._apiClient);

  /// Fetches all badges with earned/locked status.
  Future<Either<Failure, List<BadgeModel>>> getAllBadges() async {
    try {
      final response = await _apiClient.get(ApiConstants.achievements);
      final data =
          _apiClient.unwrapResponse(response.data) as Map<String, dynamic>;
      final badges = (data['badges'] as List)
          .map((json) => BadgeModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(badges);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Fetches only the user's earned badges.
  Future<Either<Failure, List<BadgeModel>>> getMyBadges() async {
    try {
      final response = await _apiClient.get(ApiConstants.myBadges);
      final data = _apiClient.unwrapResponse(response.data);
      final badges = (data as List)
          .map((json) => BadgeModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(badges);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
