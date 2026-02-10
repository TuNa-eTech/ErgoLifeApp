import 'package:equatable/equatable.dart';

/// HomeBloc events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load all home screen data
class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

/// Refresh home data (pull-to-refresh)
class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

/// Purchase a Streak Freeze (costs 500 EP)
class PurchaseStreakFreeze extends HomeEvent {
  const PurchaseStreakFreeze();
}
