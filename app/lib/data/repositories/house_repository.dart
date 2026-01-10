import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/errors/exceptions.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/house_model.dart';

/// Repository for house-related operations
class HouseRepository {
  final ApiClient _apiClient;

  HouseRepository(this._apiClient);

  /// Create a new house
  Future<Either<Failure, HouseModel>> createHouse(String name) async {
    try {
      AppLogger.info('Creating house: $name', 'HouseRepository');

      final response = await _apiClient.post(
        ApiConstants.houses,
        data: {'name': name},
      );

      final houseData = _apiClient.unwrapResponse(response.data);
      final house = HouseModel.fromJson(houseData as Map<String, dynamic>);

      AppLogger.success('House created: ${house.id}', 'HouseRepository');

      return Right(house);
    } on ServerException catch (e) {
      AppLogger.error(
        'Create house failed',
        e.message,
        null,
        'HouseRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'HouseRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Unexpected error', e, null, 'HouseRepository');
      return Left(ServerFailure(message: 'Failed to create house'));
    }
  }

  /// Get current user's house
  Future<Either<Failure, HouseModel?>> getMyHouse() async {
    try {
      AppLogger.info('Fetching my house', 'HouseRepository');

      final response = await _apiClient.get(ApiConstants.housesMe);
      if (response.data == null) {
        AppLogger.info('User has no house', 'HouseRepository');
        return const Right(null);
      }

      final houseData = _apiClient.unwrapResponse(response.data);
      final house = HouseModel.fromJson(houseData as Map<String, dynamic>);

      AppLogger.success('House loaded: ${house.name}', 'HouseRepository');
      return Right(house);
    } on NotFoundException {
      // 404 means no house - not an error
      AppLogger.info('User has no house', 'HouseRepository');
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Get house failed', e.message, null, 'HouseRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'HouseRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      // Handle DioException 404 as well
      if (e is DioException && e.response?.statusCode == 404) {
        AppLogger.info('User has no house', 'HouseRepository');
        return const Right(null);
      }
      AppLogger.error('Unexpected error', e, null, 'HouseRepository');
      return Left(ServerFailure(message: 'Failed to load house'));
    }
  }

  /// Join a house with invite code
  Future<Either<Failure, HouseModel>> joinHouse(String inviteCode) async {
    try {
      AppLogger.info('Joining house with code: $inviteCode', 'HouseRepository');

      final response = await _apiClient.post(
        ApiConstants.housesJoin,
        data: {'inviteCode': inviteCode},
      );

      final houseData = _apiClient.unwrapResponse(response.data);
      final house = HouseModel.fromJson(houseData as Map<String, dynamic>);

      AppLogger.success('Joined house: ${house.name}', 'HouseRepository');

      return Right(house);
    } on ServerException catch (e) {
      AppLogger.error('Join house failed', e.message, null, 'HouseRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'HouseRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Unexpected error', e, null, 'HouseRepository');
      return Left(ServerFailure(message: 'Failed to join house'));
    }
  }

  /// Leave current house
  Future<Either<Failure, void>> leaveHouse() async {
    try {
      AppLogger.info('Leaving house', 'HouseRepository');

      await _apiClient.post(ApiConstants.housesLeave);

      AppLogger.success('Left house successfully', 'HouseRepository');

      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Leave house failed', e.message, null, 'HouseRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'HouseRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Unexpected error', e, null, 'HouseRepository');
      return Left(ServerFailure(message: 'Failed to leave house'));
    }
  }

  /// Get invite details for sharing
  Future<Either<Failure, HouseInvite>> getInviteDetails() async {
    try {
      AppLogger.info('Fetching invite details', 'HouseRepository');

      final response = await _apiClient.get(ApiConstants.housesInvite);
      final inviteData = _apiClient.unwrapResponse(response.data);
      final invite = HouseInvite.fromJson(inviteData as Map<String, dynamic>);

      AppLogger.success(
        'Got invite code: ${invite.inviteCode}',
        'HouseRepository',
      );

      return Right(invite);
    } on ServerException catch (e) {
      AppLogger.error('Get invite failed', e.message, null, 'HouseRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'HouseRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Unexpected error', e, null, 'HouseRepository');
      return Left(ServerFailure(message: 'Failed to get invite details'));
    }
  }

  /// Preview a house before joining
  Future<Either<Failure, HousePreview>> previewHouse(String code) async {
    try {
      AppLogger.info('Previewing house: $code', 'HouseRepository');

      final response = await _apiClient.get(
        '${ApiConstants.housesPreview}/$code/preview',
      );
      final previewData = _apiClient.unwrapResponse(response.data);
      final preview = HousePreview.fromJson(
        previewData as Map<String, dynamic>,
      );

      AppLogger.success('Preview loaded: ${preview.name}', 'HouseRepository');

      return Right(preview);
    } on ServerException catch (e) {
      AppLogger.error(
        'Preview house failed',
        e.message,
        null,
        'HouseRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'HouseRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Unexpected error', e, null, 'HouseRepository');
      return Left(ServerFailure(message: 'Failed to preview house'));
    }
  }
}
