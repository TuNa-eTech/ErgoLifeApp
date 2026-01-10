import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/profile/profile_event.dart';
import 'package:ergo_life_app/blocs/profile/profile_state.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/data/repositories/auth_repository.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';
import 'package:ergo_life_app/data/repositories/user_repository.dart';

/// BLoC for managing profile screen state
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;
  final ActivityRepository _activityRepository;
  final UserRepository _userRepository;

  ProfileBloc({
    required AuthRepository authRepository,
    required ActivityRepository activityRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _activityRepository = activityRepository,
       _userRepository = userRepository,
       super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onRefreshProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  /// Load profile data
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Loading profile...', 'ProfileBloc');
    emit(const ProfileLoading());

    try {
      // Get user data
      final userResult = await _authRepository.getCurrentUser();

      await userResult.fold(
        (failure) async {
          AppLogger.error(
            'Failed to load user',
            failure.message,
            null,
            'ProfileBloc',
          );
          emit(ProfileError(message: failure.message));
        },
        (user) async {
          // Get lifetime stats
          final statsResult = await _activityRepository.getStats(period: 'all');

          final stats = statsResult.fold(
            (_) => LifetimeStats.empty(),
            (s) => LifetimeStats(
              totalPoints: s.totalPoints,
              totalActivities: s.activityCount,
              totalMinutes: s.totalDurationMinutes,
              currentStreak: s.streakDays,
              longestStreak: s.streakDays,
              estimatedCalories: 0,
            ),
          );

          AppLogger.success('Profile loaded', 'ProfileBloc');
          emit(ProfileLoaded(user: user, stats: stats));
        },
      );
    } catch (e) {
      AppLogger.error(
        'Unexpected error loading profile',
        e,
        null,
        'ProfileBloc',
      );
      emit(const ProfileError(message: 'Failed to load profile'));
    }
  }

  /// Refresh profile
  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Refreshing profile...', 'ProfileBloc');
    add(const LoadProfile());
  }

  /// Update profile
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) {
      AppLogger.warning('Cannot update - profile not loaded', 'ProfileBloc');
      return;
    }

    AppLogger.info('Updating profile...', 'ProfileBloc');
    emit(ProfileUpdating(user: currentState.user, stats: currentState.stats));

    final result = await _userRepository.updateProfile(
      displayName: event.displayName,
      avatarId: event.avatarId,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'Failed to update profile',
          failure.message,
          null,
          'ProfileBloc',
        );
        emit(const ProfileError(message: 'Failed to update profile'));
        // Restore previous state
        emit(ProfileLoaded(user: currentState.user, stats: currentState.stats));
      },
      (updatedUser) {
        AppLogger.success('Profile updated', 'ProfileBloc');
        emit(ProfileLoaded(user: updatedUser, stats: currentState.stats));
      },
    );
  }
}
