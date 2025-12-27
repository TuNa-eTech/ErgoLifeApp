import 'package:equatable/equatable.dart';

abstract class RewardsEvent extends Equatable {
  const RewardsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRewards extends RewardsEvent {
  const LoadRewards();
}

class RedeemReward extends RewardsEvent {
  final String rewardId;

  const RedeemReward(this.rewardId);

  @override
  List<Object?> get props => [rewardId];
}
