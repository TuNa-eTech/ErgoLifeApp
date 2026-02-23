import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/stats/stats_event.dart';
import 'package:ergo_life_app/blocs/stats/stats_state.dart';
import 'package:ergo_life_app/data/models/chart_data_model.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';

/// BLoC for managing stats & chart data.
///
/// Loads aggregate stats, daily breakdown (bar chart),
/// and heatmap data in parallel. Supports period
/// selection and per-widget time navigation.
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final ActivityRepository _repository;
  final String? taskName;

  StatsBloc(this._repository, {this.taskName}) : super(const StatsInitial()) {
    on<LoadStats>(_onLoadStats);
    on<RefreshStats>(_onRefreshStats);
    on<ChangeStatsTab>(_onChangeTab);
    on<ChangePeriod>(_onChangePeriod);
    on<ChangeHeatmapYear>(_onChangeHeatmapYear);
    on<ChangeCalendarMonth>(_onChangeCalendarMonth);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(const StatsLoading());
    await _fetchAll(emit, period: 'week');
  }

  Future<void> _onRefreshStats(
    RefreshStats event,
    Emitter<StatsState> emit,
  ) async {
    final currentPeriod = state is StatsLoaded
        ? (state as StatsLoaded).period
        : 'week';
    await _fetchAll(emit, period: currentPeriod);
  }

  void _onChangeTab(ChangeStatsTab event, Emitter<StatsState> emit) {
    final current = state;
    if (current is StatsLoaded) {
      emit(current.copyWith(selectedTab: event.tabIndex));
    }
  }

  /// Reload stats + breakdown with the new period.
  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<StatsState> emit,
  ) async {
    final current = state;
    if (current is StatsLoaded) {
      // Keep existing heatmap/calendar state
      await _fetchStatsAndBreakdown(
        emit,
        period: event.period,
        existing: current,
      );
    }
  }

  /// Reload heatmap data for a different year.
  Future<void> _onChangeHeatmapYear(
    ChangeHeatmapYear event,
    Emitter<StatsState> emit,
  ) async {
    final current = state;
    if (current is! StatsLoaded) return;

    final heatmapResult = await _repository.getHeatmap(year: event.year);

    List<HeatmapDataModel> heatmap = current.heatmapData;
    heatmapResult.fold((_) {}, (d) => heatmap = d);

    emit(current.copyWith(heatmapData: heatmap, heatmapYear: event.year));
  }

  /// Update calendar month (uses existing heatmap data).
  void _onChangeCalendarMonth(
    ChangeCalendarMonth event,
    Emitter<StatsState> emit,
  ) {
    final current = state;
    if (current is StatsLoaded) {
      // If navigating to a different year than the
      // heatmap, load that year's heatmap too
      if (event.year != current.heatmapYear) {
        add(ChangeHeatmapYear(event.year));
      }
      emit(
        current.copyWith(calendarYear: event.year, calendarMonth: event.month),
      );
    }
  }

  /// Maps period to breakdown days count.
  int _breakdownDays(String period) {
    return switch (period) {
      'week' => 7,
      'month' => 30,
      _ => 90,
    };
  }

  /// Fetch only stats + breakdown (period change).
  Future<void> _fetchStatsAndBreakdown(
    Emitter<StatsState> emit, {
    required String period,
    required StatsLoaded existing,
  }) async {
    final results = await Future.wait([
      _repository.getStats(period: period, taskName: taskName),
      _repository.getDailyBreakdown(days: _breakdownDays(period)),
    ]);

    StatsModel? stats;
    results[0].fold(
      (f) => emit(StatsError(message: (f as dynamic).message as String)),
      (s) => stats = s as StatsModel,
    );
    if (stats == null) return;

    List<DailyBreakdownModel> breakdown = existing.dailyBreakdown;
    results[1].fold((_) {}, (d) => breakdown = d as List<DailyBreakdownModel>);

    emit(
      existing.copyWith(
        stats: stats,
        dailyBreakdown: breakdown,
        period: period,
      ),
    );
  }

  /// Fetch all 3 data sources in parallel.
  Future<void> _fetchAll(
    Emitter<StatsState> emit, {
    required String period,
  }) async {
    final statsFuture = _repository.getStats(
      period: period,
      taskName: taskName,
    );
    final breakdownFuture = _repository.getDailyBreakdown(
      days: _breakdownDays(period),
    );
    final heatmapFuture = _repository.getHeatmap();

    final statsResult = await statsFuture;
    final breakdownResult = await breakdownFuture;
    final heatmapResult = await heatmapFuture;

    StatsModel? stats;
    statsResult.fold(
      (f) => emit(StatsError(message: f.message)),
      (s) => stats = s,
    );
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
        period: period,
      ),
    );
  }
}
