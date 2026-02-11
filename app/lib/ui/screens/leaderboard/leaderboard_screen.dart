import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/blocs/house/house_bloc.dart';
import 'package:ergo_life_app/blocs/house/house_state.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_event.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_state.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/ui/common/widgets/skeleton_loader.dart';
import 'package:ergo_life_app/ui/screens/leaderboard/widgets/join_house_banner.dart';
import 'package:ergo_life_app/ui/screens/leaderboard/widgets/leaderboard_error_view.dart';
import 'package:ergo_life_app/ui/screens/leaderboard/widgets/leaderboard_podium.dart';
import 'package:ergo_life_app/ui/screens/leaderboard/widgets/leaderboard_ranking_item.dart';
import 'package:ergo_life_app/data/models/leaderboard_model.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

    // Initial load - start with Global for current month
    _loadLeaderboard(LeaderboardScope.global);
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

    _loadLeaderboard(scope);
  }

  void _loadLeaderboard(LeaderboardScope scope) {
    context.read<LeaderboardBloc>().add(
      LoadLeaderboard(
        scope: scope,
        month: _selectedMonth.month,
        year: _selectedMonth.year,
      ),
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    final scope = _tabController.index == 0
        ? LeaderboardScope.global
        : LeaderboardScope.house;
    _loadLeaderboard(scope);
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);

    // Don't allow going past current month
    if (nextMonth.isAfter(DateTime(now.year, now.month + 1))) {
      return;
    }

    setState(() {
      _selectedMonth = nextMonth;
    });
    final scope = _tabController.index == 0
        ? LeaderboardScope.global
        : LeaderboardScope.house;
    _loadLeaderboard(scope);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  String get _monthLabel {
    return DateFormat.yMMMM().format(_selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.leaderboard),
        centerTitle: true,
        actions: [
          BlocBuilder<HouseBloc, HouseState>(
            builder: (context, houseState) {
              if (houseState is HouseLoaded && !houseState.house.isPersonal) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.card_giftcard,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    tooltip: 'Gift Shop',
                    onPressed: () => context.push(AppRouter.gifts),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Column(
            children: [
              _buildMonthSelector(isDark),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.globalLeaderboard),
                  Tab(text: AppLocalizations.of(context)!.houseLeaderboard),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildLeaderboardTab(context, LeaderboardScope.global),
          _buildLeaderboardTab(context, LeaderboardScope.house),
        ],
      ),
    );
  }

  /// Month selector row with prev/next arrows
  Widget _buildMonthSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _goToPreviousMonth,
            tooltip: 'Previous month',
          ),
          Text(
            _monthLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _isCurrentMonth
                  ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
                  : null,
            ),
            onPressed: _isCurrentMonth ? null : _goToNextMonth,
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(BuildContext context, LeaderboardScope scope) {
    return BlocConsumer<HouseBloc, HouseState>(
      listener: (context, houseState) {
        if (!mounted) return;
        if (houseState is HouseLoaded && scope == LeaderboardScope.house) {
          _loadLeaderboard(LeaderboardScope.house);
        }
      },
      builder: (context, houseState) {
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
