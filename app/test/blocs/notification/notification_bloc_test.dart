import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ergo_life_app/blocs/notification/notification_bloc.dart';
import 'package:ergo_life_app/blocs/notification/notification_event.dart';
import 'package:ergo_life_app/blocs/notification/notification_state.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/data/models/notification_model.dart';
import 'package:ergo_life_app/data/repositories/notification_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'notification_bloc_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  late NotificationBloc notificationBloc;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    notificationBloc = NotificationBloc(mockRepository);
  });

  tearDown(() {
    notificationBloc.close();
  });

  group('NotificationBloc', () {
    final tNotification1 = NotificationModel(
      id: '1',
      userId: 'user1',
      title: 'Test Notification 1',
      body: 'Test body 1',
      type: NotificationType.welcome,
      priority: NotificationPriority.medium,
      isRead: false,
      isSent: true,
      createdAt: DateTime(2024, 1, 1),
    );

    final tNotification2 = NotificationModel(
      id: '2',
      userId: 'user1',
      title: 'Test Notification 2',
      body: 'Test body 2',
      type: NotificationType.streakReminder,
      priority: NotificationPriority.high,
      isRead: false,
      isSent: true,
      createdAt: DateTime(2024, 1, 2),
    );

    final tNotification3 = NotificationModel(
      id: '3',
      userId: 'user1',
      title: 'Test Notification 3',
      body: 'Test body 3',
      type: NotificationType.activityCompleted,
      priority: NotificationPriority.low,
      isRead: true,
      isSent: true,
      createdAt: DateTime(2024, 1, 3),
    );

    final List<NotificationModel> tNotifications = [
      tNotification1,
      tNotification2,
      tNotification3,
    ];

    test('initial state should be NotificationInitial', () {
      expect(notificationBloc.state, equals(const NotificationInitial()));
    });

    group('LoadNotifications', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationLoading, NotificationLoaded] when successful',
        build: () {
          when(
            mockRepository.getNotifications(
              page: 1,
              limit: 20,
              unreadOnly: false,
            ),
          ).thenAnswer((_) async => Right(tNotifications));
          when(
            mockRepository.getUnreadCount(),
          ).thenAnswer((_) async => const Right(2));
          return notificationBloc;
        },
        act: (bloc) => bloc.add(const LoadNotifications()),
        expect: () => [
          const NotificationLoading(),
          NotificationLoaded(
            notifications: tNotifications,
            unreadCount: 2,
            currentPage: 1,
            hasMore: false,
          ),
        ],
        verify: (_) {
          verify(mockRepository.getNotifications(page: 1, limit: 20)).called(1);
          verify(mockRepository.getUnreadCount()).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationLoading, NotificationLoaded] with hasMore=false when less than 20 items',
        build: () {
          when(
            mockRepository.getNotifications(
              page: 1,
              limit: 20,
              unreadOnly: false,
            ),
          ).thenAnswer((_) async => Right([tNotification1]));
          when(
            mockRepository.getUnreadCount(),
          ).thenAnswer((_) async => const Right(1));
          return notificationBloc;
        },
        act: (bloc) => bloc.add(const LoadNotifications()),
        expect: () => [
          const NotificationLoading(),
          NotificationLoaded(
            notifications: [tNotification1],
            unreadCount: 1,
            currentPage: 1,
            hasMore: false,
          ),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationLoading, NotificationError] when repository fails',
        build: () {
          when(
            mockRepository.getNotifications(
              page: 1,
              limit: 20,
              unreadOnly: false,
            ),
          ).thenAnswer(
            (_) async =>
                Left(ServerFailure(message: 'Failed to load notifications')),
          );
          return notificationBloc;
        },
        act: (bloc) => bloc.add(const LoadNotifications()),
        expect: () => [
          const NotificationLoading(),
          NotificationError(message: 'Failed to load notifications'),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'replaces notifications when isRefresh=true',
        build: () {
          when(
            mockRepository.getNotifications(
              page: 1,
              limit: 20,
              unreadOnly: false,
            ),
          ).thenAnswer((_) async => Right([tNotification1]));
          when(
            mockRepository.getUnreadCount(),
          ).thenAnswer((_) async => const Right(1));
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: tNotifications,
          unreadCount: 2,
          currentPage: 2,
          hasMore: true,
        ),
        act: (bloc) => bloc.add(const LoadNotifications(isRefresh: true)),
        expect: () => [
          const NotificationLoading(),
          NotificationLoaded(
            notifications: [tNotification1],
            unreadCount: 1,
            currentPage: 1,
            hasMore: false,
          ),
        ],
      );
    });

    group('LoadMoreNotifications', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationLoadingMore, NotificationLoaded] with appended items',
        build: () {
          when(
            mockRepository.getNotifications(
              page: 2,
              limit: 20,
              unreadOnly: false,
            ),
          ).thenAnswer((_) async => Right([tNotification3]));
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: [tNotification1, tNotification2],
          unreadCount: 2,
          currentPage: 1,
          hasMore: true,
        ),
        act: (bloc) => bloc.add(const LoadMoreNotifications()),
        expect: () => [
          NotificationLoadingMore(
            currentNotifications: [tNotification1, tNotification2],
            currentPage: 1,
            unreadCount: 2,
          ),
          NotificationLoaded(
            notifications: [tNotification1, tNotification2, tNotification3],
            unreadCount: 2,
            currentPage: 2,
            hasMore: false,
          ),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'does nothing when hasMore=false',
        build: () => notificationBloc,
        seed: () => NotificationLoaded(
          notifications: tNotifications,
          unreadCount: 2,
          currentPage: 1,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const LoadMoreNotifications()),
        expect: () => [],
        verify: (_) {
          verifyNever(
            mockRepository.getNotifications(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              unreadOnly: anyNamed('unreadOnly'),
            ),
          );
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'does nothing when state is not NotificationLoaded',
        build: () => notificationBloc,
        seed: () => const NotificationLoading(),
        act: (bloc) => bloc.add(const LoadMoreNotifications()),
        expect: () => [],
      );
    });

    group('MarkAsRead', () {
      blocTest<NotificationBloc, NotificationState>(
        'updates notification isRead status optimistically',
        build: () {
          when(
            mockRepository.markAsRead('1'),
          ).thenAnswer((_) async => const Right(unit));
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: [tNotification1, tNotification2, tNotification3],
          unreadCount: 2,
          currentPage: 1,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const MarkAsRead('1')),
        expect: () => [isA<NotificationLoaded>()],
        verify: (bloc) {
          final state = bloc.state as NotificationLoaded;
          expect(state.notifications.length, 3);
          expect(state.notifications[0].id, '1');
          expect(state.notifications[0].isRead, true);
          expect(state.notifications[0].readAt, isNotNull);
          expect(state.notifications[1].isRead, false);
          expect(state.notifications[2].isRead, true);
          expect(state.unreadCount, 1);
          verify(mockRepository.markAsRead('1')).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'does not change state if notification already read',
        build: () {
          when(
            mockRepository.markAsRead('3'),
          ).thenAnswer((_) async => const Right(unit));
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: [tNotification3], // already read
          unreadCount: 0,
          currentPage: 1,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const MarkAsRead('3')),
        expect: () => [],
        verify: (bloc) {
          final state = bloc.state as NotificationLoaded;
          expect(state.unreadCount, 0); // Still 0
          verify(mockRepository.markAsRead('3')).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'does nothing when state is not NotificationLoaded',
        build: () => notificationBloc,
        seed: () => const NotificationLoading(),
        act: (bloc) => bloc.add(const MarkAsRead('1')),
        expect: () => [],
      );
    });

    group('MarkAllAsRead', () {
      blocTest<NotificationBloc, NotificationState>(
        'marks all notifications as read optimistically',
        build: () {
          when(
            mockRepository.markAllAsRead(),
          ).thenAnswer((_) async => const Right(unit));
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: [tNotification1, tNotification2, tNotification3],
          unreadCount: 2,
          currentPage: 1,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const MarkAllAsRead()),
        expect: () => [isA<NotificationLoaded>()],
        verify: (bloc) {
          final state = bloc.state as NotificationLoaded;
          expect(state.notifications.length, 3);
          expect(state.notifications.every((n) => n.isRead), true);
          expect(state.unreadCount, 0);
          verify(mockRepository.markAllAsRead()).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'does nothing when already all read',
        build: () {
          when(
            mockRepository.markAllAsRead(),
          ).thenAnswer((_) async => const Right(unit));
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: [tNotification3], // already read
          unreadCount: 0,
          currentPage: 1,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const MarkAllAsRead()),
        expect: () => [
          isA<NotificationLoaded>(),
        ], // Bloc always emits, even if no changes
        verify: (bloc) {
          final state = bloc.state as NotificationLoaded;
          expect(state.notifications.every((n) => n.isRead), true);
          expect(state.unreadCount, 0);
          verify(mockRepository.markAllAsRead()).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'does nothing when state is not NotificationLoaded',
        build: () => notificationBloc,
        seed: () => const NotificationInitial(),
        act: (bloc) => bloc.add(const MarkAllAsRead()),
        expect: () => [],
      );
    });

    group('DeleteNotification', () {
      blocTest<NotificationBloc, NotificationState>(
        'removes notification from list optimistically',
        build: () {
          when(
            mockRepository.deleteNotification('2'),
          ).thenAnswer((_) async => const Right(unit));
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: [tNotification1, tNotification2, tNotification3],
          unreadCount: 2,
          currentPage: 1,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const DeleteNotification('2')),
        expect: () => [isA<NotificationLoaded>()],
        verify: (bloc) {
          final state = bloc.state as NotificationLoaded;
          expect(state.notifications.length, 2);
          expect(state.notifications.any((n) => n.id == '2'), false);
          expect(state.unreadCount, 1);
          verify(mockRepository.deleteNotification('2')).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'does not change unreadCount when deleting read notification',
        build: () {
          when(
            mockRepository.deleteNotification('3'),
          ).thenAnswer((_) async => const Right(unit));
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: [tNotification1, tNotification2, tNotification3],
          unreadCount: 2,
          currentPage: 1,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const DeleteNotification('3')),
        expect: () => [isA<NotificationLoaded>()],
        verify: (bloc) {
          final state = bloc.state as NotificationLoaded;
          expect(state.notifications.length, 2);
          expect(state.notifications.any((n) => n.id == '3'), false);
          expect(state.unreadCount, 2); // unchanged
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'does nothing when state is not NotificationLoaded',
        build: () => notificationBloc,
        seed: () => NotificationError(message: 'Error'),
        act: (bloc) => bloc.add(const DeleteNotification('1')),
        expect: () => [],
      );
    });

    group('RefreshUnreadCount', () {
      blocTest<NotificationBloc, NotificationState>(
        'updates unread count when in NotificationLoaded state',
        build: () {
          when(
            mockRepository.getUnreadCount(),
          ).thenAnswer((_) async => const Right(5));
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: tNotifications,
          unreadCount: 2,
          currentPage: 1,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const RefreshUnreadCount()),
        expect: () => [isA<NotificationLoaded>()],
        verify: (bloc) {
          final state = bloc.state as NotificationLoaded;
          expect(state.unreadCount, 5); // Updated from 2 to 5
          verify(mockRepository.getUnreadCount()).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'does nothing when repository fails',
        build: () {
          when(mockRepository.getUnreadCount()).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Failed to get count')),
          );
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: tNotifications,
          unreadCount: 2,
          currentPage: 1,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const RefreshUnreadCount()),
        expect: () => [], // State unchanged on failure
      );

      blocTest<NotificationBloc, NotificationState>(
        'does nothing when state is not NotificationLoaded',
        build: () => notificationBloc,
        seed: () => const NotificationInitial(),
        act: (bloc) => bloc.add(const RefreshUnreadCount()),
        expect: () => [],
      );
    });

    group('Edge Cases', () {
      blocTest<NotificationBloc, NotificationState>(
        'handles empty notification list correctly',
        build: () {
          when(
            mockRepository.getNotifications(
              page: 1,
              limit: 20,
              unreadOnly: false,
            ),
          ).thenAnswer((_) async => const Right([]));
          when(
            mockRepository.getUnreadCount(),
          ).thenAnswer((_) async => const Right(0));
          return notificationBloc;
        },
        act: (bloc) => bloc.add(const LoadNotifications()),
        expect: () => [const NotificationLoading(), isA<NotificationLoaded>()],
        verify: (bloc) {
          final state = bloc.state as NotificationLoaded;
          expect(state.notifications.isEmpty, true);
          expect(state.unreadCount, 0);
          expect(state.hasMore, false);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'handles deleting last notification correctly',
        build: () {
          when(
            mockRepository.deleteNotification('1'),
          ).thenAnswer((_) async => const Right(unit));
          return notificationBloc;
        },
        seed: () => NotificationLoaded(
          notifications: [tNotification1],
          unreadCount: 1,
          currentPage: 1,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const DeleteNotification('1')),
        expect: () => [isA<NotificationLoaded>()],
        verify: (bloc) {
          final state = bloc.state as NotificationLoaded;
          expect(state.notifications.isEmpty, true);
          expect(state.unreadCount, 0);
          expect(state.hasMore, false);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'handles network failure gracefully',
        build: () {
          when(
            mockRepository.getNotifications(
              page: 1,
              limit: 20,
              unreadOnly: false,
            ),
          ).thenAnswer(
            (_) async =>
                Left(NetworkFailure(message: 'No internet connection')),
          );
          return notificationBloc;
        },
        act: (bloc) => bloc.add(const LoadNotifications()),
        expect: () => [
          const NotificationLoading(),
          NotificationError(message: 'No internet connection'),
        ],
      );
    });
  });
}
