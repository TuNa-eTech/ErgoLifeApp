import 'package:equatable/equatable.dart';

/// Events for the StatsBloc.
abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all stats data (aggregate + charts + heatmap).
class LoadStats extends StatsEvent {
  const LoadStats();
}

/// Refresh stats silently.
class RefreshStats extends StatsEvent {
  const RefreshStats();
}

/// Switch active tab.
class ChangeStatsTab extends StatsEvent {
  final int tabIndex;

  const ChangeStatsTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

/// Change the global stats period (week / month / all).
class ChangePeriod extends StatsEvent {
  final String period;

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Navigate heatmap to a different year.
class ChangeHeatmapYear extends StatsEvent {
  final int year;

  const ChangeHeatmapYear(this.year);

  @override
  List<Object?> get props => [year];
}

/// Navigate streak calendar to a different month.
class ChangeCalendarMonth extends StatsEvent {
  final int year;
  final int month;

  const ChangeCalendarMonth({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}
