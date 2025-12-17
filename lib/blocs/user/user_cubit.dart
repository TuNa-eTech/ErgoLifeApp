import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/user_model.dart';
import 'package:ergo_life_app/data/repositories/user_repository.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

// States
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserUpdating extends UserState {
  final UserModel user;

  const UserUpdating(this.user);

  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit(this._repository) : super(UserInitial());

  Future<void> loadUser() async {
    try {
      AppLogger.info('Loading user...', 'UserCubit');
      emit(UserLoading());

      // Try to get cached user first
      final cachedUser = _repository.getCachedUser();
      if (cachedUser != null) {
        AppLogger.success('User loaded from cache', 'UserCubit');
        emit(UserLoaded(cachedUser));
        return;
      }

      // If no cache, get default user (or fetch from API)
      final user = _repository.getDefaultUser();
      await _repository.cacheUser(user);

      AppLogger.success('User loaded successfully', 'UserCubit');
      emit(UserLoaded(user));
    } catch (e) {
      AppLogger.error('Failed to load user', e, null, 'UserCubit');
      emit(UserError(e.toString()));
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      AppLogger.info('Updating user...', 'UserCubit');
      emit(UserUpdating(user));

      // Save to cache (in real app, also send to API)
      await _repository.cacheUser(user);

      AppLogger.success('User updated successfully', 'UserCubit');
      emit(UserLoaded(user));
    } catch (e) {
      AppLogger.error('Failed to update user', e, null, 'UserCubit');
      emit(UserError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.info('Logging out...', 'UserCubit');
      await _repository.clearUserCache();
      emit(UserInitial());
      AppLogger.success('Logged out successfully', 'UserCubit');
    } catch (e) {
      AppLogger.error('Failed to logout', e, null, 'UserCubit');
      emit(UserError(e.toString()));
    }
  }
}
