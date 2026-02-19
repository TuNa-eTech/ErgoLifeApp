import 'package:equatable/equatable.dart';

/// Events for [HealthBloc].
abstract class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => [];
}

/// Check the current health connection status.
class CheckHealthStatus extends HealthEvent {
  const CheckHealthStatus();
}

/// Request health data permissions from the user.
class ConnectHealth extends HealthEvent {
  const ConnectHealth();
}

/// Dismiss the health prompt (user chose "Later").
///
/// Records the timestamp so the prompt can be shown
/// again after a cooldown period.
class DismissHealthPrompt extends HealthEvent {
  const DismissHealthPrompt();
}
