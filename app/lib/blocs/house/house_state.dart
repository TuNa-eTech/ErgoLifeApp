import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/house_model.dart';

/// HouseBloc states
abstract class HouseState extends Equatable {
  const HouseState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HouseInitial extends HouseState {
  const HouseInitial();
}

/// Loading state
class HouseLoading extends HouseState {
  const HouseLoading();
}

/// User has no house
class NoHouse extends HouseState {
  const NoHouse();
}

/// Successfully loaded house
class HouseLoaded extends HouseState {
  final HouseModel house;
  final HouseInvite? inviteDetails;

  const HouseLoaded({required this.house, this.inviteDetails});

  /// Check if current user is owner
  bool isOwner(String userId) => house.isOwner(userId);

  HouseLoaded copyWith({HouseModel? house, HouseInvite? inviteDetails}) {
    return HouseLoaded(
      house: house ?? this.house,
      inviteDetails: inviteDetails ?? this.inviteDetails,
    );
  }

  @override
  List<Object?> get props => [house, inviteDetails];
}

/// Processing house operation
class HouseProcessing extends HouseState {
  final String operation; // 'creating', 'joining', 'leaving'

  const HouseProcessing({required this.operation});

  @override
  List<Object?> get props => [operation];
}

/// Error state
class HouseError extends HouseState {
  final String message;

  const HouseError({required this.message});

  @override
  List<Object?> get props => [message];
}
