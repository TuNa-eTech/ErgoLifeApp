import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/notification/notification_event.dart';
import 'package:ergo_life_app/blocs/notification/notification_state.dart';
import 'package:ergo_life_app/data/repositories/notification_repository.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

/// BLoC to manage notification state
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  static const int _pageSize = 20;

  NotificationBloc(this._repository) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<RefreshUnreadCount>(_onRefreshUnreadCount);
  }

  /// Handle load notifications event
  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.isRefresh || state is! NotificationLoaded) {
      emit(const NotificationLoading());
    }

    final result = await _repository.getNotifications(
      page: event.page,
      limit: event.limit,
      unreadOnly: event.unreadOnly,
    );

    // Extract notifications or null
    final notifications = result.fold<List<dynamic>?>(
      (_) => null,
      (notifs) => notifs,
    );

    if (notifications == null) {
      // Handle failure case
      final failure = result.fold((f) => f, (_) => null)!;
      AppLogger.error(
        'Failed to load notifications: ${failure.message}',
        'NotificationBloc',
      );
      emit(NotificationError(message: failure.message));
      return;
    }

    // Handle success case with async operation
    final countResult = await _repository.getUnreadCount();
    final unreadCount = countResult.fold((_) => 0, (count) => count);

    emit(
      NotificationLoaded(
        notifications: notifications.cast(),
        unreadCount: unreadCount,
        hasMore: notifications.length >= event.limit,
        currentPage: event.page,
      ),
    );
  }

  /// Handle load more notifications (pagination)
  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded || !currentState.hasMore) {
      return;
    }

    // Show loading more state
    emit(
      NotificationLoadingMore(
        currentNotifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
        currentPage: currentState.currentPage,
      ),
    );

    final nextPage = currentState.currentPage + 1;
    final result = await _repository.getNotifications(
      page: nextPage,
      limit: _pageSize,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'Failed to load more notifications: ${failure.message}',
          'NotificationBloc',
        );
        // Restore previous state on error
        emit(currentState);
      },
      (newNotifications) {
        emit(
          NotificationLoaded(
            notifications: [...currentState.notifications, ...newNotifications],
            unreadCount: currentState.unreadCount,
            hasMore: newNotifications.length >= _pageSize,
            currentPage: nextPage,
          ),
        );
      },
    );
  }

  /// Handle mark as read event
  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) {
      return;
    }

    final result = await _repository.markAsRead(event.notificationId);

    result.fold(
      (failure) {
        AppLogger.error(
          'Failed to mark as read: ${failure.message}',
          'NotificationBloc',
        );
      },
      (_) {
        // Update notification in list
        final updatedNotifications = currentState.notifications.map((
          notification,
        ) {
          if (notification.id == event.notificationId && !notification.isRead) {
            return notification.copyWith(isRead: true, readAt: DateTime.now());
          }
          return notification;
        }).toList();

        // Decrement unread count if notification was unread
        final wasUnread =
            currentState.notifications
                .firstWhere((n) => n.id == event.notificationId)
                .isRead ==
            false;

        emit(
          currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: wasUnread
                ? (currentState.unreadCount - 1)
                      .clamp(0, double.infinity)
                      .toInt()
                : currentState.unreadCount,
          ),
        );

        AppLogger.debug(
          'Marked notification as read: ${event.notificationId}',
          'NotificationBloc',
        );
      },
    );
  }

  /// Handle mark all as read event
  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) {
      return;
    }

    final result = await _repository.markAllAsRead();

    result.fold(
      (failure) {
        AppLogger.error(
          'Failed to mark all as read: ${failure.message}',
          'NotificationBloc',
        );
      },
      (_) {
        // Mark all notifications as read
        final updatedNotifications = currentState.notifications.map((
          notification,
        ) {
          return notification.copyWith(
            isRead: true,
            readAt: notification.readAt ?? DateTime.now(),
          );
        }).toList();

        emit(
          currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: 0,
          ),
        );

        AppLogger.debug('Marked all notifications as read', 'NotificationBloc');
      },
    );
  }

  /// Handle delete notification event
  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) {
      return;
    }

    // Optimistically remove from list
    final notificationToDelete = currentState.notifications.firstWhere(
      (n) => n.id == event.notificationId,
    );

    final updatedNotifications = currentState.notifications
        .where((n) => n.id != event.notificationId)
        .toList();

    final newUnreadCount = notificationToDelete.isRead
        ? currentState.unreadCount
        : (currentState.unreadCount - 1).clamp(0, double.infinity).toInt();

    emit(
      currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ),
    );

    final result = await _repository.deleteNotification(event.notificationId);

    result.fold(
      (failure) {
        AppLogger.error(
          'Failed to delete notification: ${failure.message}',
          'NotificationBloc',
        );
        // Restore notification on error
        emit(currentState);
      },
      (_) {
        AppLogger.debug(
          'Deleted notification: ${event.notificationId}',
          'NotificationBloc',
        );
      },
    );
  }

  /// Handle refresh unread count event
  Future<void> _onRefreshUnreadCount(
    RefreshUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.getUnreadCount();

    result.fold(
      (failure) {
        AppLogger.error(
          'Failed to refresh unread count: ${failure.message}',
          'NotificationBloc',
        );
      },
      (count) {
        final currentState = state;
        if (currentState is NotificationLoaded) {
          emit(currentState.copyWith(unreadCount: count));
        } else {
          // Emit a lightweight loaded state with just the
          // count so the badge can render immediately.
          emit(
            NotificationLoaded(
              notifications: const [],
              unreadCount: count,
              hasMore: true,
              currentPage: 0,
            ),
          );
        }
        AppLogger.debug('Refreshed unread count: $count', 'NotificationBloc');
      },
    );
  }
}
