import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

/// Event to update user profile (name and avatar)
/// This should be called first before creating/joining a house
class UpdateProfile extends OnboardingEvent {
  final String displayName;
  final int avatarId;

  const UpdateProfile({required this.displayName, required this.avatarId});

  @override
  List<Object> get props => [displayName, avatarId];
}

/// Event to create a solo house (personal space)
/// Profile must be updated first via UpdateProfile event
class CreateSoloHouse extends OnboardingEvent {
  final String houseName;

  const CreateSoloHouse({required this.houseName});

  @override
  List<Object> get props => [houseName];
}

/// Event to create a shared house (family arena)
/// Profile must be updated first via UpdateProfile event
class CreateArenaHouse extends OnboardingEvent {
  final String houseName;

  const CreateArenaHouse({required this.houseName});

  @override
  List<Object> get props => [houseName];
}

/// Event to join an existing house using invite code
/// Profile must be updated first via UpdateProfile event
class JoinHouse extends OnboardingEvent {
  final String code;

  const JoinHouse({required this.code});

  @override
  List<Object> get props => [code];
}
