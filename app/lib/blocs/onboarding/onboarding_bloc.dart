import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_event.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_state.dart';
import 'package:ergo_life_app/data/services/api_service.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:dio/dio.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final ApiService _apiService;

  OnboardingBloc({required ApiService apiService})
      : _apiService = apiService,
        super(const OnboardingInitial()) {
    on<CreateSoloHouse>(_onCreateSoloHouse);
    on<CreateArenaHouse>(_onCreateArenaHouse);
  }

  Future<void> _onCreateSoloHouse(
    CreateSoloHouse event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    try {
      // 1. Update profile
      await _apiService.put(
        '/users/me',
        data: {
          'displayName': event.displayName,
          'avatarId': event.avatarId,
        },
      );

      // 2. Create solo house
      await _apiService.post(
        '/houses',
        data: {
          'name': event.houseName,
        },
      );

      emit(const OnboardingSuccess('Personal Space Created! 🏡'));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
        // User already has a house, treat as success
        emit(const OnboardingSuccess('Personal Space Ready! 🏡'));
      } else {
        AppLogger.error('Create Solo House Failed', e, null, 'OnboardingBloc');
        emit(OnboardingError(e.toString()));
      }
    }
  }

  Future<void> _onCreateArenaHouse(
    CreateArenaHouse event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    try {
      // 1. Update profile
      await _apiService.put(
        '/users/me',
        data: {
          'displayName': event.displayName,
          'avatarId': event.avatarId,
        },
      );

      // 2. Create shared house
      await _apiService.post(
        '/houses',
        data: {
          'name': event.houseName,
        },
      );

      emit(const OnboardingSuccess('Arena Created! 🎉'));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
        emit(const OnboardingSuccess('Arena Ready! 🎉'));
      } else {
        AppLogger.error('Create Arena House Failed', e, null, 'OnboardingBloc');
        emit(OnboardingError(e.toString()));
      }
    }
  }
}
