import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_event.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_state.dart';
import 'package:ergo_life_app/data/repositories/user_repository.dart';
import 'package:ergo_life_app/data/repositories/house_repository.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final UserRepository _userRepository;
  final HouseRepository _houseRepository;

  // Track if profile has been updated to avoid duplicate calls
  bool _profileUpdated = false;

  OnboardingBloc({
    required UserRepository userRepository,
    required HouseRepository houseRepository,
  }) : _userRepository = userRepository,
       _houseRepository = houseRepository,
       super(const OnboardingInitial()) {
    on<UpdateProfile>(_onUpdateProfile);
    on<CreateSoloHouse>(_onCreateSoloHouse);
    on<CreateArenaHouse>(_onCreateArenaHouse);
    on<JoinHouse>(_onJoinHouse);
  }

  /// Update user profile (name and avatar)
  /// This should be called first before creating/joining a house
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    try {
      final result = await _userRepository
          .updateProfile(
            displayName: event.displayName,
            avatarId: event.avatarId,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          );

      result.fold((failure) => emit(OnboardingError(failure.message)), (_) {
        _profileUpdated = true;
        emit(const OnboardingProfileUpdated());
      });
    } catch (e) {
      AppLogger.error('Update Profile Failed', e, null, 'OnboardingBloc');
      emit(OnboardingError(_getErrorMessage(e)));
    }
  }

  /// Create a solo house (personal space)
  /// Profile must be updated first
  Future<void> _onCreateSoloHouse(
    CreateSoloHouse event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!_profileUpdated) {
      emit(const OnboardingError('Please complete your profile first'));
      return;
    }

    emit(const OnboardingLoading());
    try {
      final houseResult = await _houseRepository
          .createHouse(event.houseName)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          );

      houseResult.fold((failure) {
        // 409 means user already has a house, treat as success
        if (failure.message.contains('409') ||
            failure.message.contains('already')) {
          emit(const OnboardingSuccess('Personal Space Ready! 🏡'));
        } else {
          emit(OnboardingError(failure.message));
        }
      }, (_) => emit(const OnboardingSuccess('Personal Space Created! 🏡')));
    } catch (e) {
      AppLogger.error('Create Solo House Failed', e, null, 'OnboardingBloc');
      emit(OnboardingError(_getErrorMessage(e)));
    }
  }

  /// Create a shared house (family arena)
  /// Profile must be updated first
  Future<void> _onCreateArenaHouse(
    CreateArenaHouse event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!_profileUpdated) {
      emit(const OnboardingError('Please complete your profile first'));
      return;
    }

    emit(const OnboardingLoading());
    try {
      final houseResult = await _houseRepository
          .createHouse(event.houseName)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          );

      houseResult.fold((failure) {
        if (failure.message.contains('409') ||
            failure.message.contains('already')) {
          emit(const OnboardingSuccess('Arena Ready! 🎉'));
        } else {
          emit(OnboardingError(failure.message));
        }
      }, (_) => emit(const OnboardingSuccess('Arena Created! 🎉')));
    } catch (e) {
      AppLogger.error('Create Arena House Failed', e, null, 'OnboardingBloc');
      emit(OnboardingError(_getErrorMessage(e)));
    }
  }

  /// Join an existing house using invite code
  /// Profile must be updated first
  Future<void> _onJoinHouse(
    JoinHouse event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!_profileUpdated) {
      emit(const OnboardingError('Please complete your profile first'));
      return;
    }

    emit(const OnboardingLoading());
    try {
      final joinResult = await _houseRepository
          .joinHouse(event.code)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          );

      joinResult.fold(
        (failure) => emit(OnboardingError(failure.message)),
        (_) => emit(const OnboardingSuccess('Joined House Successfully! 🏠')),
      );
    } catch (e) {
      AppLogger.error('Join House Failed', e, null, 'OnboardingBloc');
      emit(OnboardingError(_getErrorMessage(e)));
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(Object error) {
    if (error.toString().contains('timed out')) {
      return 'Request timed out. Please check your connection and try again.';
    }
    return error.toString();
  }
}
