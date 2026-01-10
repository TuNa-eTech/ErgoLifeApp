import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/user_model.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';

/// ProfileBloc states
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Successfully loaded profile
class ProfileLoaded extends ProfileState {
  final UserModel user;
  final LifetimeStats stats;

  const ProfileLoaded({required this.user, required this.stats});

  /// Get membership duration
  String get membershipDuration {
    if (user.createdAt == null) return 'New member';

    final now = DateTime.now();
    final created = user.createdAt!;
    final diff = now.difference(created);

    if (diff.inDays < 30) {
      return '${diff.inDays} days';
    } else if (diff.inDays < 365) {
      final months = diff.inDays ~/ 30;
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      final years = diff.inDays ~/ 365;
      return '$years year${years > 1 ? 's' : ''}';
    }
  }

  ProfileLoaded copyWith({UserModel? user, LifetimeStats? stats}) {
    return ProfileLoaded(user: user ?? this.user, stats: stats ?? this.stats);
  }

  @override
  List<Object?> get props => [user, stats];
}

/// Updating profile
class ProfileUpdating extends ProfileState {
  final UserModel user;
  final LifetimeStats stats;

  const ProfileUpdating({required this.user, required this.stats});

  @override
  List<Object?> get props => [user, stats];
}

/// Error state
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
