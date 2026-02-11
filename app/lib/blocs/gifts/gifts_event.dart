import 'package:equatable/equatable.dart';

abstract class GiftsEvent extends Equatable {
  const GiftsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the gift catalog (rewards + balance + house members).
class LoadGiftCatalog extends GiftsEvent {
  /// The locale code for translations (e.g. 'en', 'vi').
  final String locale;

  const LoadGiftCatalog({this.locale = 'vi'});

  @override
  List<Object?> get props => [locale];
}

/// Send a gift to a house member.
class SendGift extends GiftsEvent {
  final String giftRewardId;
  final String receiverId;
  final String? message;

  const SendGift({
    required this.giftRewardId,
    required this.receiverId,
    this.message,
  });

  @override
  List<Object?> get props => [giftRewardId, receiverId, message];
}

/// Load the gift history (sent and/or received).
class LoadGiftHistory extends GiftsEvent {
  final String? type;
  final int page;

  const LoadGiftHistory({this.type, this.page = 1});

  @override
  List<Object?> get props => [type, page];
}
