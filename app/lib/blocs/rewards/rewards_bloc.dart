import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/rewards/rewards_event.dart';
import 'package:ergo_life_app/blocs/rewards/rewards_state.dart';
import 'package:ergo_life_app/data/repositories/reward_repository.dart';
import 'package:ergo_life_app/data/repositories/user_repository.dart';

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  final RewardRepository _rewardRepository;
  final UserRepository _userRepository;

  RewardsBloc({
    required RewardRepository rewardRepository,
    required UserRepository userRepository,
  }) : _rewardRepository = rewardRepository,
       _userRepository = userRepository,
       super(const RewardsInitial()) {
    on<LoadRewards>(_onLoadRewards);
    on<RedeemReward>(_onRedeemReward);
  }

  Future<void> _onLoadRewards(
    LoadRewards event,
    Emitter<RewardsState> emit,
  ) async {
    emit(const RewardsLoading());

    // Fetch rewards and user balance (for display)
    try {
      // Fetch user first (or parallel if safe, but user fetch throws on error)
      final user = await _userRepository.fetchUser();

      final result = await _rewardRepository.getRewards();

      result.fold(
        (failure) => emit(RewardsError(failure.message)),
        (rewards) => emit(
          RewardsLoaded(rewards: rewards, userBalance: user.walletBalance),
        ),
      );
    } catch (e) {
      emit(RewardsError('Failed to load user profile: $e'));
    }
  }

  Future<void> _onRedeemReward(
    RedeemReward event,
    Emitter<RewardsState> emit,
  ) async {
    // Optimistic or waiting? Let's wait.
    // We don't want to clear the list, so we might need a processing state or just use a dialog.
    // Simplifying: Just call API and then reload.

    final result = await _rewardRepository.redeemReward(event.rewardId);

    result.fold((failure) => emit(RewardsError(failure.message)), (_) {
      // Reload to update balance and list if needed
      add(const LoadRewards());
      emit(const RewardRedeemSuccess('Redeemed successfully!'));
    });
  }
}
