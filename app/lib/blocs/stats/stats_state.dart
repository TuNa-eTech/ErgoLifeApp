import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/data/models/chart_data_model.dart';

/// States for the StatsBloc.
abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class StatsInitial extends StatsState {
  const StatsInitial();
}

/// Loading all stats data.
class StatsLoading extends StatsState {
  const StatsLoading();
}

/// All stats data loaded.
class StatsLoaded extends StatsState {
  final StatsModel stats;
  final List<DailyBreakdownModel> dailyBreakdown;
  final List<HeatmapDataModel> heatmapData;
  final int selectedTab;

  /// Global period: 'week', 'month', or 'all'.
  final String period;

  /// Year displayed in the heatmap.
  final int heatmapYear;

  /// Year + month displayed in the streak calendar.
  final int calendarYear;
  final int calendarMonth;

  StatsLoaded({
    required this.stats,
    required this.dailyBreakdown,
    required this.heatmapData,
    this.selectedTab = 0,
    this.period = 'week',
    int? heatmapYear,
    int? calendarYear,
    int? calendarMonth,
  }) : heatmapYear = heatmapYear ?? DateTime.now().year,
       calendarYear = calendarYear ?? DateTime.now().year,
       calendarMonth = calendarMonth ?? DateTime.now().month;

  StatsLoaded copyWith({
    StatsModel? stats,
    List<DailyBreakdownModel>? dailyBreakdown,
    List<HeatmapDataModel>? heatmapData,
    int? selectedTab,
    String? period,
    int? heatmapYear,
    int? calendarYear,
    int? calendarMonth,
  }) {
    return StatsLoaded(
      stats: stats ?? this.stats,
      dailyBreakdown: dailyBreakdown ?? this.dailyBreakdown,
      heatmapData: heatmapData ?? this.heatmapData,
      selectedTab: selectedTab ?? this.selectedTab,
      period: period ?? this.period,
      heatmapYear: heatmapYear ?? this.heatmapYear,
      calendarYear: calendarYear ?? this.calendarYear,
      calendarMonth: calendarMonth ?? this.calendarMonth,
    );
  }

  @override
  List<Object?> get props => [
    stats,
    dailyBreakdown,
    heatmapData,
    selectedTab,
    period,
    heatmapYear,
    calendarYear,
    calendarMonth,
  ];
}

/// Error loading stats.
class StatsError extends StatsState {
  final String message;

  const StatsError({required this.message});

  @override
  List<Object?> get props => [message];
}
