import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_event.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_state.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/leaderboard_model.dart';

class LeaderboardScreen extends StatelessWidget {
  final LeaderboardBloc leaderboardBloc;

  const LeaderboardScreen({
    super.key,
    required this.leaderboardBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaderboardBloc>.value(
      value: leaderboardBloc..add(const LoadLeaderboard()),
      child: const LeaderboardView(),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LeaderboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LeaderboardBloc>().add(const RefreshLeaderboard());
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildPodium(context, state.podium, isDark),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Rankings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = state.runnersUp[index];
                        return _buildRankingItem(
                          context,
                          entry,
                          state.isMe(entry),
                          isDark,
                        );
                      },
                      childCount: state.runnersUp.length,
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
            );
          }

          if (state is LeaderboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSubDark
                          : AppColors.textSubLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<LeaderboardBloc>()
                        .add(const RefreshLeaderboard()),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No leaderboard data'));
        },
      ),
    );
  }

  Widget _buildPodium(
    BuildContext context,
    List<LeaderboardEntry> podium,
    bool isDark,
  ) {
    if (podium.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.indigo.shade900, Colors.purple.shade900]
              : [Colors.indigo.shade300, Colors.purple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (podium.length > 1) _buildPodiumItem(podium[1], 2, 80, isDark),
          if (podium.isNotEmpty) _buildPodiumItem(podium[0], 1, 100, isDark),
          if (podium.length > 2) _buildPodiumItem(podium[2], 3, 60, isDark),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    LeaderboardEntry entry,
    int position,
    double height,
    bool isDark,
  ) {
    final colors = {
      1: Colors.amber,
      2: Colors.grey.shade400,
      3: Colors.brown.shade400,
    };
    final color = colors[position] ?? Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            image: entry.user.avatarUrl != null
                ? DecorationImage(
                    image: NetworkImage(entry.user.avatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: entry.user.avatarUrl == null
              ? Center(
                  child: Text(
                    (entry.user.name ?? 'U').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          (entry.user.name ?? 'User').split(' ').first,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          entry.formattedPoints,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              position.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem(
    BuildContext context,
    LeaderboardEntry entry,
    bool isMe,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe
            ? (isDark
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.1))
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
              image: entry.user.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(entry.user.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: entry.user.avatarUrl == null
                ? Center(
                    child: Text(
                      (entry.user.name ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.user.name ?? 'User',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  '${entry.activityCount} activities',
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
          Text(
            entry.formattedPoints,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isMe ? AppColors.primary : AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
