import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class SubmitProfileStep extends OnboardingEvent {
  final String displayName;
  final int avatarId;

  const SubmitProfileStep({
    required this.displayName,
    required this.avatarId,
  });

  @override
  List<Object> get props => [displayName, avatarId];
}

class CreateSoloHouse extends OnboardingEvent {
  final String houseName;
  final String displayName; // Need to resend as per current flow logic
  final int avatarId;

  const CreateSoloHouse({
    required this.houseName,
    required this.displayName,
    required this.avatarId,
  });

  @override
  List<Object> get props => [houseName, displayName, avatarId];
}

class CreateArenaHouse extends OnboardingEvent {
  final String houseName;
  final String displayName;
  final int avatarId;

  const CreateArenaHouse({
    required this.houseName,
    required this.displayName,
    required this.avatarId,
  });

  @override
  List<Object> get props => [houseName, displayName, avatarId];
}

class JoinHouse extends OnboardingEvent {
  final String code;
  final String displayName;
  final int avatarId;

  const JoinHouse({
    required this.code,
    required this.displayName,
    required this.avatarId,
  });

  @override
  List<Object> get props => [code, displayName, avatarId];
}
