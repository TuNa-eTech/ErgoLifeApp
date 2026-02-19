import 'package:equatable/equatable.dart';

/// States for [HealthBloc].
abstract class HealthState extends Equatable {
  const HealthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before checking health status.
class HealthInitial extends HealthState {
  const HealthInitial();
}

/// Health service is available and authorized.
class HealthConnected extends HealthState {
  /// User's body weight from HealthKit in kg, if available.
  final double? bodyWeight;

  const HealthConnected({this.bodyWeight});

  @override
  List<Object?> get props => [bodyWeight];
}

/// Health service is not connected.
///
/// [shouldShowPrompt] indicates whether the soft-prompt
/// sheet should be displayed to the user.
class HealthDisconnected extends HealthState {
  final bool shouldShowPrompt;

  const HealthDisconnected({this.shouldShowPrompt = false});

  @override
  List<Object?> get props => [shouldShowPrompt];
}

/// Health authorization is in progress.
class HealthConnecting extends HealthState {
  const HealthConnecting();
}

/// Health connection failed with an error.
class HealthError extends HealthState {
  final String message;

  const HealthError(this.message);

  @override
  List<Object?> get props => [message];
}
