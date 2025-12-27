import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/reward_model.dart';

abstract class RewardsState extends Equatable {
  const RewardsState();

  @override
  List<Object?> get props => [];
}

class RewardsInitial extends RewardsState {
  const RewardsInitial();
}

class RewardsLoading extends RewardsState {
  const RewardsLoading();
}

class RewardsLoaded extends RewardsState {
  final List<RewardModel> rewards;
  final int userBalance;

  const RewardsLoaded({
    required this.rewards,
    required this.userBalance,
  });

  @override
  List<Object?> get props => [rewards, userBalance];
}

class RewardsError extends RewardsState {
  final String message;

  const RewardsError(this.message);

  @override
  List<Object?> get props => [message];
}

class RewardRedeemSuccess extends RewardsState {
  final String message;

  const RewardRedeemSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
