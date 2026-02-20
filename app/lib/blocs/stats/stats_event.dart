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
