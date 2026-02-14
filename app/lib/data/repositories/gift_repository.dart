import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/data/models/gift_reward_model.dart';
import 'package:ergo_life_app/data/models/gift_transaction_model.dart';
import 'package:ergo_life_app/data/models/house_member_model.dart';

/// Response model for the gift catalog endpoint.
class GiftCatalogResponse {
  final List<GiftRewardModel> rewards;
  final int userBalance;
  final List<HouseMemberModel> houseMembers;

  const GiftCatalogResponse({
    required this.rewards,
    required this.userBalance,
    required this.houseMembers,
  });
}

/// Response model for the send gift endpoint.
class SendGiftResponse {
  final GiftTransactionModel transaction;
  final int previousBalance;
  final int pointsSpent;
  final int newBalance;

  const SendGiftResponse({
    required this.transaction,
    required this.previousBalance,
    required this.pointsSpent,
    required this.newBalance,
  });
}

/// Response model for the gift history endpoint.
class GiftHistoryResponse {
  final List<GiftTransactionModel> gifts;
  final int total;
  final bool hasMore;

  const GiftHistoryResponse({
    required this.gifts,
    required this.total,
    required this.hasMore,
  });
}

/// Repository for gift-related API calls.
class GiftRepository {
  final ApiClient _apiClient;

  GiftRepository(this._apiClient);

  /// Fetch the gift catalog with rewards, balance, and house members.
  Future<Either<Failure, GiftCatalogResponse>> getCatalog({
    String locale = 'vi',
  }) async {
    try {
      final response = await _apiClient.get(
        '/gifts/catalog',
        queryParameters: {'locale': locale},
      );
      final data =
          _apiClient.unwrapResponse(response.data) as Map<String, dynamic>;

      final rewards = (data['rewards'] as List<dynamic>? ?? <dynamic>[])
          .map((json) => GiftRewardModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final members = (data['houseMembers'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (json) => HouseMemberModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return Right(
        GiftCatalogResponse(
          rewards: rewards,
          userBalance: data['userBalance'] as int? ?? 0,
          houseMembers: members,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch gift catalog',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Send a gift to a house member.
  Future<Either<Failure, SendGiftResponse>> sendGift({
    required String giftRewardId,
    required String receiverId,
    String? message,
    String locale = 'vi',
  }) async {
    try {
      final response = await _apiClient.post(
        '/gifts/send',
        data: {
          'giftRewardId': giftRewardId,
          'receiverId': receiverId,
          if (message != null && message.isNotEmpty) 'message': message,
          'locale': locale,
        },
      );
      final data =
          _apiClient.unwrapResponse(response.data) as Map<String, dynamic>;
      final transactionJson = data['transaction'] as Map<String, dynamic>;
      final walletJson = data['wallet'] as Map<String, dynamic>;

      return Right(
        SendGiftResponse(
          transaction: GiftTransactionModel.fromJson(transactionJson),
          previousBalance: walletJson['previousBalance'] as int? ?? 0,
          pointsSpent: walletJson['pointsSpent'] as int? ?? 0,
          newBalance: walletJson['newBalance'] as int? ?? 0,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data['message'] ?? 'Failed to send gift',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Fetch paginated gift history.
  Future<Either<Failure, GiftHistoryResponse>> getHistory({
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/gifts/history',
        queryParameters: {
          if (type != null) 'type': type,
          'page': page,
          'limit': limit,
        },
      );
      final data =
          _apiClient.unwrapResponse(response.data) as Map<String, dynamic>;

      final gifts = (data['gifts'] as List<dynamic>)
          .map(
            (json) =>
                GiftTransactionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return Right(
        GiftHistoryResponse(
          gifts: gifts,
          total: data['total'] as int? ?? 0,
          hasMore: data['hasMore'] as bool? ?? false,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch gift history',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
