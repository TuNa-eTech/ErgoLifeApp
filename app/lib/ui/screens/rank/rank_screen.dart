import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_event.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_state.dart';

class RankScreen extends StatelessWidget {
  final LeaderboardBloc leaderboardBloc;

  const RankScreen({super.key, required this.leaderboardBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaderboardBloc>.value(
      value: leaderboardBloc..add(const LoadLeaderboard()),
      child: const RankView(),
    );
  }
}

class RankView extends StatelessWidget {
  const RankView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: BlocConsumer<LeaderboardBloc, LeaderboardState>(
        listener: (context, state) {
          if (state is LeaderboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () => context.read<LeaderboardBloc>().add(
                    const LoadLeaderboard(),
                  ),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LeaderboardLoading) {
            return _buildLoadingState(isDark);
          }

          if (state is LeaderboardError) {
            return _buildErrorState(context, state.message, isDark);
          }

          if (state is LeaderboardLoaded) {
            return _buildLoadedState(context, state, isDark);
          }

          return _buildLoadingState(isDark);
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.red.shade300 : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load leaderboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<LeaderboardBloc>().add(const LoadLeaderboard()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    LeaderboardLoaded state,
    bool isDark,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LeaderboardBloc>().add(const RefreshLeaderboard());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            _buildHeader(context, isDark),
            if (state.podium.isNotEmpty) _buildPodium(state, isDark),
            if (state.runnersUp.isNotEmpty) _buildRunnersUp(state, isDark),
            if (state.podium.isEmpty && state.runnersUp.isEmpty)
              _buildEmptyState(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COMPETITION',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This Week',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
            ],
          ),
          // Invite Members Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.person_add, color: Colors.white),
              tooltip: 'Invite Members',
              onPressed: () {
                // Navigate to invite screen
                context.push(AppRouter.inviteMembers);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(LeaderboardLoaded state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (state.podium.length > 1)
            Expanded(child: _buildPodiumUser(state.podium[1], 2, 140, isDark)),
          // 1st place
          if (state.podium.isNotEmpty)
            Expanded(child: _buildPodiumUser(state.podium[0], 1, 180, isDark)),
          // 3rd place
          if (state.podium.length > 2)
            Expanded(child: _buildPodiumUser(state.podium[2], 3, 120, isDark)),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(dynamic entry, int rank, double height, bool isDark) {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];
    final color = colors[rank - 1];
    final user = entry.user;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            image: user.photoUrl != null
                ? DecorationImage(
                    image: NetworkImage(user.photoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: user.photoUrl == null ? Colors.grey.shade300 : null,
          ),
          child: user.photoUrl == null
              ? Icon(Icons.person, color: Colors.grey.shade600, size: 30)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          user.name ?? 'User',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${entry.points} EP',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.8),
                color.withValues(alpha: 0.4),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRunnersUp(LeaderboardLoaded state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Other Rankings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 16),
          ...state.runnersUp.asMap().entries.map((entry) {
            final index = entry.key;
            final leaderboardEntry = entry.value;
            return _buildLeaderboardTile(leaderboardEntry, index + 4, isDark);
          }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(dynamic entry, int rank, bool isDark) {
    final user = entry.user;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: user.photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(user.photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: user.photoUrl == null ? Colors.grey.shade300 : null,
            ),
            child: user.photoUrl == null
                ? Icon(Icons.person, color: Colors.grey.shade600)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  'Level ${user.level ?? 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSubDark
                        : AppColors.textSubLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.points}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
              const Text(
                'EP',
                style: TextStyle(fontSize: 12, color: AppColors.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No rankings yet',
              style: TextStyle(
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start completing tasks to climb the leaderboard!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
