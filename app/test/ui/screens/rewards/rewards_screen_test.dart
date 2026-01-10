import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:ergo_life_app/ui/screens/rewards/rewards_screen.dart';
import 'package:ergo_life_app/blocs/rewards/rewards_bloc.dart';
import 'package:ergo_life_app/blocs/rewards/rewards_event.dart';
import 'package:ergo_life_app/blocs/rewards/rewards_state.dart';
import 'package:ergo_life_app/data/models/reward_model.dart';

class MockRewardsBloc extends MockBloc<RewardsEvent, RewardsState>
    implements RewardsBloc {}

void main() {
  late MockRewardsBloc mockRewardsBloc;

  setUp(() {
    mockRewardsBloc = MockRewardsBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<RewardsBloc>.value(
        value: mockRewardsBloc,
        child: const RewardsView(),
      ),
    );
  }

  testWidgets(
    'RewardsScreen displays loading indicator when state is RewardsLoading',
    (tester) async {
      when(() => mockRewardsBloc.state).thenReturn(const RewardsLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'RewardsScreen displays rewards and balance when state is RewardsLoaded',
    (tester) async {
      final rewards = [
        RewardModel(
          id: '1',
          title: 'Gift Card',
          cost: 100,
          icon: '🎁',
          description: 'Test Description',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];
      when(
        () => mockRewardsBloc.state,
      ).thenReturn(RewardsLoaded(rewards: rewards, userBalance: 500));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('500 EP'), findsOneWidget);
      expect(find.text('Gift Card'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Redeem'), findsOneWidget);
    },
  );

  testWidgets('Redeem button triggers RedeemReward event', (tester) async {
    final rewards = [
      RewardModel(
        id: '1',
        title: 'Gift Card',
        cost: 100,
        icon: '🎁',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
    when(
      () => mockRewardsBloc.state,
    ).thenReturn(RewardsLoaded(rewards: rewards, userBalance: 500));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Redeem'));
    verify(() => mockRewardsBloc.add(const RedeemReward('1'))).called(1);
  });
}
