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

  const StatsLoaded({
    required this.stats,
    required this.dailyBreakdown,
    required this.heatmapData,
    this.selectedTab = 0,
  });

  StatsLoaded copyWith({
    StatsModel? stats,
    List<DailyBreakdownModel>? dailyBreakdown,
    List<HeatmapDataModel>? heatmapData,
    int? selectedTab,
  }) {
    return StatsLoaded(
      stats: stats ?? this.stats,
      dailyBreakdown: dailyBreakdown ?? this.dailyBreakdown,
      heatmapData: heatmapData ?? this.heatmapData,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [stats, dailyBreakdown, heatmapData, selectedTab];
}

/// Error loading stats.
class StatsError extends StatsState {
  final String message;

  const StatsError({required this.message});

  @override
  List<Object?> get props => [message];
}
