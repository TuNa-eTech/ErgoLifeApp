import 'package:equatable/equatable.dart';

/// HouseBloc events
abstract class HouseEvent extends Equatable {
  const HouseEvent();

  @override
  List<Object?> get props => [];
}

/// Load house data
class LoadHouse extends HouseEvent {
  const LoadHouse();
}

/// Create new house
class CreateHouse extends HouseEvent {
  final String name;

  const CreateHouse({required this.name});

  @override
  List<Object?> get props => [name];
}

/// Join house with invite code
class JoinHouse extends HouseEvent {
  final String inviteCode;

  const JoinHouse({required this.inviteCode});

  @override
  List<Object?> get props => [inviteCode];
}

/// Leave current house
class LeaveHouse extends HouseEvent {
  const LeaveHouse();
}

/// Get invite details
class GetInviteDetails extends HouseEvent {
  const GetInviteDetails();
}
