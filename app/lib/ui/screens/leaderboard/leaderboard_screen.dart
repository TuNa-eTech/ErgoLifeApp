import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/house/house_bloc.dart';
import 'package:ergo_life_app/blocs/house/house_state.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_event.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_state.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/ui/common/widgets/skeleton_loader.dart';
import 'package:ergo_life_app/ui/screens/leaderboard/widgets/join_house_banner.dart';
import 'package:ergo_life_app/ui/screens/leaderboard/widgets/leaderboard_error_view.dart';
import 'package:ergo_life_app/ui/screens/leaderboard/widgets/leaderboard_podium.dart';
import 'package:ergo_life_app/ui/screens/leaderboard/widgets/leaderboard_ranking_item.dart';
import 'package:ergo_life_app/data/models/leaderboard_model.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

class LeaderboardScreen extends StatelessWidget {
  final LeaderboardBloc leaderboardBloc;

  const LeaderboardScreen({super.key, required this.leaderboardBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaderboardBloc>.value(
      value: leaderboardBloc,
      child: const LeaderboardView(),
    );
  }
}

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Initial load - start with Global
    context.read<LeaderboardBloc>().add(
      const LoadLeaderboard(scope: LeaderboardScope.global),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (_tabController.indexIsChanging) return;

    final scope = _tabController.index == 0
        ? LeaderboardScope.global
        : LeaderboardScope.house;

    context.read<LeaderboardBloc>().add(LoadLeaderboard(scope: scope));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.leaderboard),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.globalLeaderboard),
            Tab(text: AppLocalizations.of(context)!.houseLeaderboard),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe to avoid accidental refresh triggers
        children: [
          _buildLeaderboardTab(context, LeaderboardScope.global),
          _buildLeaderboardTab(context, LeaderboardScope.house),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(BuildContext context, LeaderboardScope scope) {
    return BlocConsumer<HouseBloc, HouseState>(
      listener: (context, houseState) {
        // Reload if house state changes and we are on the relevant tab
        if (!mounted) return;
        if (houseState is HouseLoaded && scope == LeaderboardScope.house) {
          context.read<LeaderboardBloc>().add(
            const LoadLeaderboard(scope: LeaderboardScope.house),
          );
        }
      },
      builder: (context, houseState) {
        // Check special case: House Tab but User is in Personal House
        if (scope == LeaderboardScope.house &&
            houseState is HouseLoaded &&
            houseState.house.isPersonal) {
          return Column(
            children: [
              const JoinHouseBanner(),
              Expanded(child: _buildLeaderboardContent(context, scope)),
            ],
          );
        }

        return _buildLeaderboardContent(context, scope);
      },
    );
  }

  Widget _buildLeaderboardContent(
    BuildContext context,
    LeaderboardScope scope,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return const LeaderboardScreenSkeleton();
        }

        if (state is LeaderboardLoaded) {
          // Verify we are showing the correct data for the requested scope
          // This prevents flashing old data from a different scope
          if (state.leaderboard.scope != scope) {
            return const LeaderboardScreenSkeleton();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<LeaderboardBloc>().add(const RefreshLeaderboard());
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: LeaderboardPodium(podium: state.podium),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.rankings,
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final entry = state.runnersUp[index];
                    return LeaderboardRankingItem(
                      entry: entry,
                      isMe: state.isMe(entry),
                    );
                  }, childCount: state.runnersUp.length),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          );
        }

        if (state is LeaderboardError) {
          return LeaderboardErrorView(message: state.message);
        }

        return Center(
          child: Text(AppLocalizations.of(context)!.noLeaderboardData),
        );
      },
    );
  }
}
