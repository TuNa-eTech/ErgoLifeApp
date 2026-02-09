import 'package:dartz/dartz.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/errors/exceptions.dart';
import 'package:ergo_life_app/data/models/notification_model.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

/// Repository for notification-related API calls
class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  /// Get paginated notifications
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.notifications,
        queryParameters: {
          'page': page,
          'limit': limit,
          'unreadOnly': unreadOnly,
        },
      );

      final data = _apiClient.unwrapResponse(response.data);
      final notificationsList = data is List
          ? data
          : (data as Map<String, dynamic>)['notifications'] as List? ?? [];
      final notifications = notificationsList
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      AppLogger.debug(
        'Fetched ${notifications.length} notifications',
        'NotificationRepository',
      );
      return Right(notifications);
    } on ServerException catch (e) {
      AppLogger.error(
        'Server error fetching notifications: ${e.message}',
        'NotificationRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'Network error fetching notifications',
        'NotificationRepository',
      );
      return const Left(NetworkFailure(message: 'Unable to connect to server'));
    } catch (e) {
      AppLogger.error(
        'Unexpected error fetching notifications: $e',
        'NotificationRepository',
      );
      return Left(ServerFailure(message: 'Failed to fetch notifications'));
    }
  }

  /// Mark a notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _apiClient.patch(
        ApiConstants.notificationMarkAsRead(notificationId),
      );

      AppLogger.debug(
        'Marked notification as read: $notificationId',
        'NotificationRepository',
      );
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error(
        'Server error marking notification as read: ${e.message}',
        'NotificationRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'Network error marking notification as read',
        'NotificationRepository',
      );
      return const Left(NetworkFailure(message: 'Unable to connect to server'));
    } catch (e) {
      AppLogger.error(
        'Unexpected error marking notification as read: $e',
        'NotificationRepository',
      );
      return Left(
        ServerFailure(message: 'Failed to mark notification as read'),
      );
    }
  }

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _apiClient.patch(ApiConstants.notificationsReadAll);

      AppLogger.debug(
        'Marked all notifications as read',
        'NotificationRepository',
      );
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error(
        'Server error marking all as read: ${e.message}',
        'NotificationRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'Network error marking all as read',
        'NotificationRepository',
      );
      return const Left(NetworkFailure(message: 'Unable to connect to server'));
    } catch (e) {
      AppLogger.error(
        'Unexpected error marking all as read: $e',
        'NotificationRepository',
      );
      return Left(ServerFailure(message: 'Failed to mark all as read'));
    }
  }

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _apiClient.delete(ApiConstants.notificationById(notificationId));

      AppLogger.debug(
        'Deleted notification: $notificationId',
        'NotificationRepository',
      );
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error(
        'Server error deleting notification: ${e.message}',
        'NotificationRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'Network error deleting notification',
        'NotificationRepository',
      );
      return const Left(NetworkFailure(message: 'Unable to connect to server'));
    } catch (e) {
      AppLogger.error(
        'Unexpected error deleting notification: $e',
        'NotificationRepository',
      );
      return Left(ServerFailure(message: 'Failed to delete notification'));
    }
  }

  /// Get unread notification count
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.notificationsUnreadCount,
      );

      final data = _apiClient.unwrapResponse(response.data);
      final count = data['count'] as int? ?? 0;

      AppLogger.debug('Unread count: $count', 'NotificationRepository');
      return Right(count);
    } on ServerException catch (e) {
      AppLogger.error(
        'Server error fetching unread count: ${e.message}',
        'NotificationRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'Network error fetching unread count',
        'NotificationRepository',
      );
      return const Left(NetworkFailure(message: 'Unable to connect to server'));
    } catch (e) {
      AppLogger.error(
        'Unexpected error fetching unread count: $e',
        'NotificationRepository',
      );
      return Left(ServerFailure(message: 'Failed to fetch unread count'));
    }
  }
}
