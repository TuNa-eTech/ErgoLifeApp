import 'package:equatable/equatable.dart';

/// ProfileBloc events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load profile data
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// Refresh profile
class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}

/// Update profile
class UpdateProfile extends ProfileEvent {
  final String? displayName;
  final int? avatarId;

  const UpdateProfile({this.displayName, this.avatarId});

  @override
  List<Object?> get props => [displayName, avatarId];
}
