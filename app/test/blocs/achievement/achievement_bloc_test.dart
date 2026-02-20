import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ergo_life_app/blocs/achievement/achievement_bloc.dart';
import 'package:ergo_life_app/blocs/achievement/achievement_event.dart';
import 'package:ergo_life_app/blocs/achievement/achievement_state.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/data/models/badge_model.dart';
import 'package:ergo_life_app/data/repositories/achievement_repository.dart';

import 'achievement_bloc_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AchievementRepository>()])
void main() {
  late AchievementBloc bloc;
  late MockAchievementRepository mockRepository;

  const tBadges = [
    BadgeModel(
      id: 'b1',
      code: 'FIRST_TIMER',
      category: 'activity',
      icon: 'emoji_events',
      color: '#4CAF50',
      rarity: 'COMMON',
      name: 'First Timer',
      description: 'Complete your first activity',
      isEarned: true,
      progress: 1.0,
      unlockedAt: '2026-02-20T08:00:00Z',
      conditionType: 'total_activities',
      conditionValue: 1,
      currentValue: 5,
    ),
    BadgeModel(
      id: 'b2',
      code: 'STREAK_7',
      category: 'streak',
      icon: 'local_fire_department',
      color: '#FF5722',
      rarity: 'COMMON',
      name: '7-Day Warrior',
      isEarned: false,
      progress: 0.43,
      conditionType: 'streak',
      conditionValue: 7,
      currentValue: 3,
    ),
  ];

  setUp(() {
    mockRepository = MockAchievementRepository();
    bloc = AchievementBloc(mockRepository);
  });

  tearDown(() => bloc.close());

  test('initial state is AchievementInitial', () {
    expect(bloc.state, const AchievementInitial());
  });

  group('LoadAllBadges', () {
    blocTest<AchievementBloc, AchievementState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(
          mockRepository.getAllBadges(),
        ).thenAnswer((_) async => const Right(tBadges));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadAllBadges()),
      expect: () => [
        const AchievementLoading(),
        const AchievementLoaded(badges: tBadges, earnedCount: 1, totalCount: 2),
      ],
    );

    blocTest<AchievementBloc, AchievementState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(mockRepository.getAllBadges()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Network error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadAllBadges()),
      expect: () => [
        const AchievementLoading(),
        const AchievementError(message: 'Network error'),
      ],
    );
  });

  group('RefreshBadges', () {
    const tRefreshedBadges = [
      BadgeModel(
        id: 'b1',
        code: 'FIRST_TIMER',
        category: 'activity',
        icon: 'emoji_events',
        color: '#4CAF50',
        rarity: 'COMMON',
        name: 'First Timer',
        description: 'Complete your first activity',
        isEarned: true,
        progress: 1.0,
        unlockedAt: '2026-02-20T08:00:00Z',
        conditionType: 'total_activities',
        conditionValue: 1,
        currentValue: 10,
      ),
      BadgeModel(
        id: 'b2',
        code: 'STREAK_7',
        category: 'streak',
        icon: 'local_fire_department',
        color: '#FF5722',
        rarity: 'COMMON',
        name: '7-Day Warrior',
        isEarned: true,
        progress: 1.0,
        unlockedAt: '2026-02-20T09:00:00Z',
        conditionType: 'streak',
        conditionValue: 7,
        currentValue: 7,
      ),
    ];

    blocTest<AchievementBloc, AchievementState>(
      'emits updated Loaded on success',
      build: () {
        when(
          mockRepository.getAllBadges(),
        ).thenAnswer((_) async => const Right(tRefreshedBadges));
        return bloc;
      },
      seed: () => const AchievementLoaded(
        badges: tBadges,
        earnedCount: 1,
        totalCount: 2,
      ),
      act: (bloc) => bloc.add(const RefreshBadges()),
      expect: () => [
        const AchievementLoaded(
          badges: tRefreshedBadges,
          earnedCount: 2,
          totalCount: 2,
        ),
      ],
    );

    blocTest<AchievementBloc, AchievementState>(
      'keeps current state on failure',
      build: () {
        when(
          mockRepository.getAllBadges(),
        ).thenAnswer((_) async => const Left(ServerFailure(message: 'err')));
        return bloc;
      },
      seed: () => const AchievementLoaded(
        badges: tBadges,
        earnedCount: 1,
        totalCount: 2,
      ),
      act: (bloc) => bloc.add(const RefreshBadges()),
      expect: () => [],
    );
  });
}
