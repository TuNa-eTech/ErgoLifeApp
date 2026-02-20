import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/achievement/achievement_event.dart';
import 'package:ergo_life_app/blocs/achievement/achievement_state.dart';
import 'package:ergo_life_app/data/repositories/achievement_repository.dart';

/// BLoC for managing achievement/badge state.
class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final AchievementRepository _repository;

  AchievementBloc(this._repository) : super(const AchievementInitial()) {
    on<LoadAllBadges>(_onLoadAllBadges);
    on<RefreshBadges>(_onRefreshBadges);
  }

  Future<void> _onLoadAllBadges(
    LoadAllBadges event,
    Emitter<AchievementState> emit,
  ) async {
    emit(const AchievementLoading());

    final result = await _repository.getAllBadges();

    result.fold((failure) => emit(AchievementError(message: failure.message)), (
      badges,
    ) {
      final earned = badges.where((b) => b.isEarned).length;
      emit(
        AchievementLoaded(
          badges: badges,
          earnedCount: earned,
          totalCount: badges.length,
        ),
      );
    });
  }

  Future<void> _onRefreshBadges(
    RefreshBadges event,
    Emitter<AchievementState> emit,
  ) async {
    final result = await _repository.getAllBadges();

    result.fold((_) {}, (badges) {
      final earned = badges.where((b) => b.isEarned).length;
      emit(
        AchievementLoaded(
          badges: badges,
          earnedCount: earned,
          totalCount: badges.length,
        ),
      );
    });
  }
}
