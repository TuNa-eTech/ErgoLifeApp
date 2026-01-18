import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// Profile has been successfully updated
/// User can now proceed to create/join a house
class OnboardingProfileUpdated extends OnboardingState {
  const OnboardingProfileUpdated();
}

class OnboardingSuccess extends OnboardingState {
  final String message;

  const OnboardingSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
