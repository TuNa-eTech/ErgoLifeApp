import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/gift_reward_model.dart';
import 'package:ergo_life_app/data/models/gift_transaction_model.dart';
import 'package:ergo_life_app/data/models/house_member_model.dart';

abstract class GiftsState extends Equatable {
  const GiftsState();

  @override
  List<Object?> get props => [];
}

class GiftsInitial extends GiftsState {
  const GiftsInitial();
}

class GiftsLoading extends GiftsState {
  const GiftsLoading();
}

/// Catalog loaded with rewards, balance, and house members.
class GiftCatalogLoaded extends GiftsState {
  final List<GiftRewardModel> rewards;
  final int userBalance;
  final List<HouseMemberModel> houseMembers;

  const GiftCatalogLoaded({
    required this.rewards,
    required this.userBalance,
    required this.houseMembers,
  });

  @override
  List<Object?> get props => [rewards, userBalance, houseMembers];
}

/// Gift sent successfully.
class GiftSentSuccess extends GiftsState {
  final String message;
  final int newBalance;

  const GiftSentSuccess({required this.message, required this.newBalance});

  @override
  List<Object?> get props => [message, newBalance];
}

/// Sending gift in progress (for loading indicator on send button).
class GiftSending extends GiftsState {
  const GiftSending();
}

/// Gift history loaded.
class GiftHistoryLoaded extends GiftsState {
  final List<GiftTransactionModel> gifts;
  final int total;
  final bool hasMore;
  final String? filterType;

  const GiftHistoryLoaded({
    required this.gifts,
    required this.total,
    required this.hasMore,
    this.filterType,
  });

  @override
  List<Object?> get props => [gifts, total, hasMore, filterType];
}

class GiftsError extends GiftsState {
  final String message;

  const GiftsError(this.message);

  @override
  List<Object?> get props => [message];
}
