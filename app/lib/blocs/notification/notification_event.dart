import 'package:equatable/equatable.dart';

/// Base class for all notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications with pagination
class LoadNotifications extends NotificationEvent {
  final int page;
  final int limit;
  final bool unreadOnly;
  final bool isRefresh;

  const LoadNotifications({
    this.page = 1,
    this.limit = 20,
    this.unreadOnly = false,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, unreadOnly, isRefresh];
}

/// Mark a single notification as read
class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read
class MarkAllAsRead extends NotificationEvent {
  const MarkAllAsRead();
}

/// Delete a notification
class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Refresh unread count
class RefreshUnreadCount extends NotificationEvent {
  const RefreshUnreadCount();
}

/// Load more notifications (pagination)
class LoadMoreNotifications extends NotificationEvent {
  const LoadMoreNotifications();
}
