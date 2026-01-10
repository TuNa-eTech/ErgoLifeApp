import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_event.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_state.dart';
import 'package:ergo_life_app/data/repositories/user_repository.dart';
import 'package:ergo_life_app/data/repositories/house_repository.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final UserRepository _userRepository;
  final HouseRepository _houseRepository;

  OnboardingBloc({
    required UserRepository userRepository,
    required HouseRepository houseRepository,
  }) : _userRepository = userRepository,
       _houseRepository = houseRepository,
       super(const OnboardingInitial()) {
    on<CreateSoloHouse>(_onCreateSoloHouse);
    on<CreateArenaHouse>(_onCreateArenaHouse);
    on<JoinHouse>(_onJoinHouse);
  }

  Future<void> _onCreateSoloHouse(
    CreateSoloHouse event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    try {
      // 1. Update profile
      final profileResult = await _userRepository.updateProfile(
        displayName: event.displayName,
        avatarId: event.avatarId,
      );

      if (profileResult.isLeft()) {
        emit(OnboardingError(profileResult.fold((l) => l.message, (_) => '')));
        return;
      }

      // 2. Create solo house
      final houseResult = await _houseRepository.createHouse(event.houseName);

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
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onCreateArenaHouse(
    CreateArenaHouse event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    try {
      // 1. Update profile
      final profileResult = await _userRepository.updateProfile(
        displayName: event.displayName,
        avatarId: event.avatarId,
      );

      if (profileResult.isLeft()) {
        emit(OnboardingError(profileResult.fold((l) => l.message, (_) => '')));
        return;
      }

      // 2. Create shared house
      final houseResult = await _houseRepository.createHouse(event.houseName);

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
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onJoinHouse(
    JoinHouse event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    try {
      // 1. Update profile
      final profileResult = await _userRepository.updateProfile(
        displayName: event.displayName,
        avatarId: event.avatarId,
      );

      if (profileResult.isLeft()) {
        emit(OnboardingError(profileResult.fold((l) => l.message, (_) => '')));
        return;
      }

      // 2. Join house
      final joinResult = await _houseRepository.joinHouse(event.code);

      joinResult.fold(
        (failure) => emit(OnboardingError(failure.message)),
        (_) => emit(const OnboardingSuccess('Joined House Successfully! 🏠')),
      );
    } catch (e) {
      AppLogger.error('Join House Failed', e, null, 'OnboardingBloc');
      emit(OnboardingError(e.toString()));
    }
  }
}
