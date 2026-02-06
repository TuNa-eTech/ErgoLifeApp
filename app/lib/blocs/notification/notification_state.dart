import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/notification_model.dart';

/// Base class for all notification states
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state (first load or refresh)
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Successfully loaded notifications
class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool hasMore;
  final int currentPage;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasMore, currentPage];

  /// Create copy with modifications
  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Loading more notifications (pagination)
class NotificationLoadingMore extends NotificationState {
  final List<NotificationModel> currentNotifications;
  final int unreadCount;
  final int currentPage;

  const NotificationLoadingMore({
    required this.currentNotifications,
    required this.unreadCount,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [currentNotifications, unreadCount, currentPage];
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}
