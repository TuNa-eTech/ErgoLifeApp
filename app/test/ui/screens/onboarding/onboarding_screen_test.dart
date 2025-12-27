import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:ergo_life_app/ui/screens/onboarding/onboarding_screen.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_bloc.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_event.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_state.dart';

class MockOnboardingBloc extends MockBloc<OnboardingEvent, OnboardingState> implements OnboardingBloc {}

void main() {
  late MockOnboardingBloc mockOnboardingBloc;

  setUp(() {
    mockOnboardingBloc = MockOnboardingBloc();
  });

  testWidgets('OnboardingScreen renders "Who are you?" initially', (tester) async {
    when(() => mockOnboardingBloc.state).thenReturn(const OnboardingInitial());

    await tester.pumpWidget(MaterialApp(home: OnboardingScreen(bloc: mockOnboardingBloc)));

    expect(find.text('Choose your avatar'), findsOneWidget);
    expect(find.text('Pick one for the leaderboard (optional)'), findsOneWidget);
  });
  
  testWidgets('Button is disabled when name is empty', (tester) async {
      when(() => mockOnboardingBloc.state).thenReturn(const OnboardingInitial());
      
      await tester.pumpWidget(MaterialApp(home: OnboardingScreen(bloc: mockOnboardingBloc)));
      
      expect(find.byType(TextField), findsOneWidget);
  });
}
