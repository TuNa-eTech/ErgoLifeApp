import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/data/models/reward_model.dart';

class RewardRepository {
  final ApiClient _apiClient;

  RewardRepository(this._apiClient);

  Future<Either<Failure, List<RewardModel>>> getRewards() async {
    try {
      final response = await _apiClient.get('/rewards');
      final List<dynamic> data = response.data['rewards'];
      final rewards = data.map((json) => RewardModel.fromJson(json)).toList();
      return Right(rewards);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Failed to fetch rewards',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> redeemReward(String rewardId) async {
    try {
      await _apiClient.post('/rewards/$rewardId/redeem', data: {});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Failed to redeem reward',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
