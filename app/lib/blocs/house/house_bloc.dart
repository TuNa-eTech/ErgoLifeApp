import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/house/house_event.dart';
import 'package:ergo_life_app/blocs/house/house_state.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/repositories/house_repository.dart';

/// BLoC for managing house/group state
class HouseBloc extends Bloc<HouseEvent, HouseState> {
  final HouseRepository _houseRepository;

  HouseBloc({
    required HouseRepository houseRepository,
  })  : _houseRepository = houseRepository,
        super(const HouseInitial()) {
    on<LoadHouse>(_onLoadHouse);
    on<CreateHouse>(_onCreateHouse);
    on<JoinHouse>(_onJoinHouse);
    on<LeaveHouse>(_onLeaveHouse);
    on<GetInviteDetails>(_onGetInviteDetails);
  }

  /// Load house data
  Future<void> _onLoadHouse(
    LoadHouse event,
    Emitter<HouseState> emit,
  ) async {
    AppLogger.info('Loading house...', 'HouseBloc');
    emit(const HouseLoading());

    final result = await _houseRepository.getMyHouse();

    result.fold(
      (failure) {
        AppLogger.error('Failed to load house', failure.message, null, 'HouseBloc');
        emit(HouseError(message: failure.message));
      },
      (house) {
        if (house == null) {
          AppLogger.info('User has no house', 'HouseBloc');
          emit(const NoHouse());
        } else {
          AppLogger.success('House loaded: ${house.name}', 'HouseBloc');
          emit(HouseLoaded(house: house));
        }
      },
    );
  }

  /// Create new house
  Future<void> _onCreateHouse(
    CreateHouse event,
    Emitter<HouseState> emit,
  ) async {
    AppLogger.info('Creating house: ${event.name}', 'HouseBloc');
    emit(const HouseProcessing(operation: 'creating'));

    final result = await _houseRepository.createHouse(event.name);

    result.fold(
      (failure) {
        AppLogger.error('Failed to create house', failure.message, null, 'HouseBloc');
        emit(HouseError(message: failure.message));
      },
      (house) {
        AppLogger.success('House created: ${house.name}', 'HouseBloc');
        emit(HouseLoaded(house: house));
      },
    );
  }

  /// Join house with code
  Future<void> _onJoinHouse(
    JoinHouse event,
    Emitter<HouseState> emit,
  ) async {
    AppLogger.info('Joining house with code: ${event.inviteCode}', 'HouseBloc');
    emit(const HouseProcessing(operation: 'joining'));

    final result = await _houseRepository.joinHouse(event.inviteCode);

    result.fold(
      (failure) {
        AppLogger.error('Failed to join house', failure.message, null, 'HouseBloc');
        emit(HouseError(message: failure.message));
      },
      (house) {
        AppLogger.success('Joined house: ${house.name}', 'HouseBloc');
        emit(HouseLoaded(house: house));
      },
    );
  }

  /// Leave current house
  Future<void> _onLeaveHouse(
    LeaveHouse event,
    Emitter<HouseState> emit,
  ) async {
    AppLogger.info('Leaving house...', 'HouseBloc');
    emit(const HouseProcessing(operation: 'leaving'));

    final result = await _houseRepository.leaveHouse();

    result.fold(
      (failure) {
        AppLogger.error('Failed to leave house', failure.message, null, 'HouseBloc');
        emit(HouseError(message: failure.message));
      },
      (_) {
        AppLogger.success('Left house successfully', 'HouseBloc');
        emit(const NoHouse());
      },
    );
  }

  /// Get invite details
  Future<void> _onGetInviteDetails(
    GetInviteDetails event,
    Emitter<HouseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HouseLoaded) {
      AppLogger.warning('Cannot get invite - no house loaded', 'HouseBloc');
      return;
    }

    AppLogger.info('Getting invite details...', 'HouseBloc');

    final result = await _houseRepository.getInviteDetails();

    result.fold(
      (failure) {
        AppLogger.error('Failed to get invite', failure.message, null, 'HouseBloc');
        // Don't emit error, just keep current state
      },
      (invite) {
        AppLogger.success('Got invite code: ${invite.inviteCode}', 'HouseBloc');
        emit(currentState.copyWith(inviteDetails: invite));
      },
    );
  }
}
