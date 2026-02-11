import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/gifts/gifts_event.dart';
import 'package:ergo_life_app/blocs/gifts/gifts_state.dart';
import 'package:ergo_life_app/data/models/gift_transaction_model.dart';
import 'package:ergo_life_app/data/repositories/gift_repository.dart';

/// BLoC for managing the gift catalog, sending gifts, and history.
class GiftsBloc extends Bloc<GiftsEvent, GiftsState> {
  final GiftRepository _giftRepository;

  /// Cached last successful catalog for optimistic re-emit.
  GiftCatalogLoaded? _lastCatalog;

  /// Cached locale from the last catalog load.
  String _lastLocale = 'vi';

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
    _lastLocale = event.locale;

    final result = await _giftRepository.getCatalog(locale: event.locale);

    result.fold((failure) => emit(GiftsError(failure.message)), (catalog) {
      final loaded = GiftCatalogLoaded(
        rewards: catalog.rewards,
        userBalance: catalog.userBalance,
        houseMembers: catalog.houseMembers,
      );
      _lastCatalog = loaded;
      emit(loaded);
    });
  }

  Future<void> _onSendGift(SendGift event, Emitter<GiftsState> emit) async {
    emit(const GiftSending());

    final result = await _giftRepository.sendGift(
      giftRewardId: event.giftRewardId,
      receiverId: event.receiverId,
      message: event.message,
      locale: _lastLocale,
    );

    result.fold((failure) => emit(GiftsError(failure.message)), (response) {
      emit(
        GiftSentSuccess(
          message: 'Gift sent successfully! 🎁',
          newBalance: response.newBalance,
        ),
      );
      // Optimistic update: re-emit catalog with new balance,
      // avoiding a full reload flash.
      if (_lastCatalog != null) {
        final updated = GiftCatalogLoaded(
          rewards: _lastCatalog!.rewards,
          userBalance: response.newBalance,
          houseMembers: _lastCatalog!.houseMembers,
        );
        _lastCatalog = updated;
        emit(updated);
      } else {
        add(LoadGiftCatalog(locale: _lastLocale));
      }
    });
  }

  Future<void> _onLoadHistory(
    LoadGiftHistory event,
    Emitter<GiftsState> emit,
  ) async {
    // Only show full loading on first page.
    if (event.page <= 1) {
      emit(const GiftsLoading());
    }

    final result = await _giftRepository.getHistory(
      type: event.type,
      page: event.page,
    );

    result.fold((failure) => emit(GiftsError(failure.message)), (history) {
      // Append items for subsequent pages.
      final existing = state is GiftHistoryLoaded && event.page > 1
          ? (state as GiftHistoryLoaded).gifts
          : <GiftTransactionModel>[];

      emit(
        GiftHistoryLoaded(
          gifts: [...existing, ...history.gifts],
          total: history.total,
          hasMore: history.hasMore,
          filterType: event.type,
          currentPage: event.page,
        ),
      );
    });
  }
}
