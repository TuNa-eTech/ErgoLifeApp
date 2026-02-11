import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/gifts/gifts_event.dart';
import 'package:ergo_life_app/blocs/gifts/gifts_state.dart';
import 'package:ergo_life_app/data/repositories/gift_repository.dart';

/// BLoC for managing the gift catalog, sending gifts, and history.
class GiftsBloc extends Bloc<GiftsEvent, GiftsState> {
  final GiftRepository _giftRepository;

  GiftsBloc({required GiftRepository giftRepository})
    : _giftRepository = giftRepository,
      super(const GiftsInitial()) {
    on<LoadGiftCatalog>(_onLoadCatalog);
    on<SendGift>(_onSendGift);
    on<LoadGiftHistory>(_onLoadHistory);
  }

  Future<void> _onLoadCatalog(
    LoadGiftCatalog event,
    Emitter<GiftsState> emit,
  ) async {
    emit(const GiftsLoading());

    final result = await _giftRepository.getCatalog();

    result.fold(
      (failure) => emit(GiftsError(failure.message)),
      (catalog) => emit(
        GiftCatalogLoaded(
          rewards: catalog.rewards,
          userBalance: catalog.userBalance,
          houseMembers: catalog.houseMembers,
        ),
      ),
    );
  }

  Future<void> _onSendGift(SendGift event, Emitter<GiftsState> emit) async {
    emit(const GiftSending());

    final result = await _giftRepository.sendGift(
      giftRewardId: event.giftRewardId,
      receiverId: event.receiverId,
      message: event.message,
    );

    result.fold((failure) => emit(GiftsError(failure.message)), (response) {
      emit(
        GiftSentSuccess(
          message: 'Gift sent successfully! 🎁',
          newBalance: response.newBalance,
        ),
      );
      // Reload catalog to update balance
      add(const LoadGiftCatalog());
    });
  }

  Future<void> _onLoadHistory(
    LoadGiftHistory event,
    Emitter<GiftsState> emit,
  ) async {
    emit(const GiftsLoading());

    final result = await _giftRepository.getHistory(
      type: event.type,
      page: event.page,
    );

    result.fold(
      (failure) => emit(GiftsError(failure.message)),
      (history) => emit(
        GiftHistoryLoaded(
          gifts: history.gifts,
          total: history.total,
          hasMore: history.hasMore,
          filterType: event.type,
        ),
      ),
    );
  }
}
