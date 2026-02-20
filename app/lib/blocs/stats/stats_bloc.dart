import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/stats/stats_event.dart';
import 'package:ergo_life_app/blocs/stats/stats_state.dart';
import 'package:ergo_life_app/data/models/chart_data_model.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';

/// BLoC for managing stats & chart data.
///
/// Loads aggregate stats, daily breakdown (bar chart),
/// and heatmap data in parallel.
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final ActivityRepository _repository;
  final String? taskName;

  StatsBloc(this._repository, {this.taskName}) : super(const StatsInitial()) {
    on<LoadStats>(_onLoadStats);
    on<RefreshStats>(_onRefreshStats);
    on<ChangeStatsTab>(_onChangeTab);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(const StatsLoading());
    await _fetchAll(emit);
  }

  Future<void> _onRefreshStats(
    RefreshStats event,
    Emitter<StatsState> emit,
  ) async {
    await _fetchAll(emit);
  }

  void _onChangeTab(ChangeStatsTab event, Emitter<StatsState> emit) {
    final current = state;
    if (current is StatsLoaded) {
      emit(current.copyWith(selectedTab: event.tabIndex));
    }
  }

  Future<void> _fetchAll(Emitter<StatsState> emit) async {
    // Fetch all 3 data sources in parallel
    final statsFuture = _repository.getStats(period: 'all', taskName: taskName);
    final breakdownFuture = _repository.getDailyBreakdown(days: 7);
    final heatmapFuture = _repository.getHeatmap();

    final statsResult = await statsFuture;
    final breakdownResult = await breakdownFuture;
    final heatmapResult = await heatmapFuture;

    // Check for errors
    StatsModel? stats;
    statsResult.fold((f) {
      emit(StatsError(message: f.message));
    }, (s) => stats = s);
    if (stats == null) return;

    List<DailyBreakdownModel> breakdown = const [];
    breakdownResult.fold((_) {}, (d) => breakdown = d);

    List<HeatmapDataModel> heatmap = const [];
    heatmapResult.fold((_) {}, (d) => heatmap = d);

    final currentTab = state is StatsLoaded
        ? (state as StatsLoaded).selectedTab
        : 0;

    emit(
      StatsLoaded(
        stats: stats!,
        dailyBreakdown: breakdown,
        heatmapData: heatmap,
        selectedTab: currentTab,
      ),
    );
  }
}
