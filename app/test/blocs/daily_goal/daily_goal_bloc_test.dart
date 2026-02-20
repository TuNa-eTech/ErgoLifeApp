import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ergo_life_app/blocs/daily_goal/daily_goal_bloc.dart';
import 'package:ergo_life_app/blocs/daily_goal/daily_goal_event.dart';
import 'package:ergo_life_app/blocs/daily_goal/daily_goal_state.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/data/models/daily_goal_model.dart';
import 'package:ergo_life_app/data/repositories/daily_goal_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'daily_goal_bloc_test.mocks.dart';

@GenerateMocks([DailyGoalRepository])
void main() {
  late DailyGoalBloc bloc;
  late MockDailyGoalRepository mockRepository;

  const tGoal = DailyGoalModel(
    id: 'goal-uuid',
    date: '2026-02-20',
    targetEp: 500,
    targetDuration: 30,
    targetActivities: 2,
    currentEp: 200,
    currentDuration: 15,
    currentActivities: 1,
    isPerfectDay: false,
    epProgress: 0.4,
    durationProgress: 0.5,
    activitiesProgress: 0.5,
  );

  const tSettings = GoalSettingsModel(
    targetEp: 500,
    targetDuration: 30,
    targetActivities: 2,
  );

  setUp(() {
    mockRepository = MockDailyGoalRepository();
    bloc = DailyGoalBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('DailyGoalBloc', () {
    test('initial state should be DailyGoalInitial', () {
      expect(bloc.state, equals(const DailyGoalInitial()));
    });

    group('LoadTodayGoal', () {
      blocTest<DailyGoalBloc, DailyGoalState>(
        'emits [Loading, Loaded] when successful',
        build: () {
          when(
            mockRepository.getTodayGoal(),
          ).thenAnswer((_) async => const Right(tGoal));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTodayGoal()),
        expect: () => [
          const DailyGoalLoading(),
          const DailyGoalLoaded(goal: tGoal),
        ],
        verify: (_) {
          verify(mockRepository.getTodayGoal()).called(1);
        },
      );

      blocTest<DailyGoalBloc, DailyGoalState>(
        'emits [Loading, Error] when fails',
        build: () {
          when(mockRepository.getTodayGoal()).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Failed to load goal')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTodayGoal()),
        expect: () => [
          const DailyGoalLoading(),
          const DailyGoalError(message: 'Failed to load goal'),
        ],
      );
    });

    group('RefreshGoal', () {
      const tRefreshedGoal = DailyGoalModel(
        id: 'goal-uuid',
        date: '2026-02-20',
        targetEp: 500,
        targetDuration: 30,
        targetActivities: 2,
        currentEp: 300,
        currentDuration: 20,
        currentActivities: 2,
        isPerfectDay: false,
        epProgress: 0.6,
        durationProgress: 0.67,
        activitiesProgress: 1.0,
      );

      blocTest<DailyGoalBloc, DailyGoalState>(
        'emits updated Loaded on success',
        build: () {
          when(
            mockRepository.getTodayGoal(),
          ).thenAnswer((_) async => const Right(tRefreshedGoal));
          return bloc;
        },
        seed: () => const DailyGoalLoaded(goal: tGoal),
        act: (bloc) => bloc.add(const RefreshGoal()),
        expect: () => [const DailyGoalLoaded(goal: tRefreshedGoal)],
      );

      blocTest<DailyGoalBloc, DailyGoalState>(
        'does nothing on failure (silent)',
        build: () {
          when(mockRepository.getTodayGoal()).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Network error')),
          );
          return bloc;
        },
        seed: () => const DailyGoalLoaded(goal: tGoal),
        act: (bloc) => bloc.add(const RefreshGoal()),
        expect: () => [],
      );
    });

    group('UpdateGoalSettings', () {
      blocTest<DailyGoalBloc, DailyGoalState>(
        'calls repo and re-loads goal on success',
        build: () {
          when(
            mockRepository.updateGoalSettings(tSettings),
          ).thenAnswer((_) async => const Right(tSettings));
          when(
            mockRepository.getTodayGoal(),
          ).thenAnswer((_) async => const Right(tGoal));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const UpdateGoalSettings(
            targetEp: 500,
            targetDuration: 30,
            targetActivities: 2,
          ),
        ),
        expect: () => [
          const DailyGoalLoading(),
          const DailyGoalLoaded(goal: tGoal),
        ],
        verify: (_) {
          verify(mockRepository.updateGoalSettings(tSettings)).called(1);
          verify(mockRepository.getTodayGoal()).called(1);
        },
      );

      blocTest<DailyGoalBloc, DailyGoalState>(
        'emits Error when settings update fails',
        build: () {
          when(mockRepository.updateGoalSettings(tSettings)).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Save failed')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          const UpdateGoalSettings(
            targetEp: 500,
            targetDuration: 30,
            targetActivities: 2,
          ),
        ),
        expect: () => [const DailyGoalError(message: 'Save failed')],
      );
    });
  });
}
