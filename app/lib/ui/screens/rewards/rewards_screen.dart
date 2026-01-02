import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/rewards/rewards_bloc.dart';
import 'package:ergo_life_app/blocs/rewards/rewards_event.dart';
import 'package:ergo_life_app/blocs/rewards/rewards_state.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/reward_model.dart';

class RewardsScreen extends StatelessWidget {
  final RewardsBloc rewardsBloc;

  const RewardsScreen({
    super.key,
    required this.rewardsBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RewardsBloc>.value(
      value: rewardsBloc..add(const LoadRewards()),
      child: const RewardsView(),
    );
  }
}

class RewardsView extends StatelessWidget {
  const RewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Rewards Shop'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<RewardsBloc, RewardsState>(
        listener: (context, state) {
          if (state is RewardsError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is RewardRedeemSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
           if (state is RewardsLoading) {
             return const Center(child: CircularProgressIndicator());
           }
           
           if (state is RewardsLoaded) {
             return Column(
               children: [
                 _buildBalanceCard(context, state.userBalance, isDark),
                 Expanded(
                   child: RefreshIndicator(
                     onRefresh: () async {
                       context.read<RewardsBloc>().add(const LoadRewards());
                     },
                     child: ListView.builder(
                       padding: const EdgeInsets.all(16),
                       itemCount: state.rewards.length,
                       itemBuilder: (context, index) {
                         return _buildRewardItem(context, state.rewards[index], state.userBalance, isDark);
                       },
                     ),
                   ),
                 ),
               ],
             );
           }
           
           return const Center(child: Text("No rewards available"));
        },
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, int balance, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR BALANCE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$balance EP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ),
              ),
            ],
          ),
          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildRewardItem(BuildContext context, RewardModel reward, int userBalance, bool isDark) {
    final canAfford = userBalance >= reward.cost;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(reward.icon, style: const TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ),
                ),
                if (reward.description != null)
                Text(
                  reward.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${reward.cost} EP',
                   style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canAfford 
              ? () => context.read<RewardsBloc>().add(RedeemReward(reward.id))
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford ? AppColors.secondary : Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Redeem', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
