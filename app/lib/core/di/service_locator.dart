import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:ergo_life_app/core/network/network_info.dart';

// Data - Services
import 'package:ergo_life_app/data/services/api_service.dart';
import 'package:ergo_life_app/data/services/auth_service.dart';
import 'package:ergo_life_app/data/services/storage_service.dart';

// Data - Repositories
import 'package:ergo_life_app/data/repositories/user_repository.dart';
import 'package:ergo_life_app/data/repositories/session_repository.dart';

// BLoCs/Cubits
import 'package:ergo_life_app/blocs/user/user_cubit.dart';
import 'package:ergo_life_app/blocs/session/session_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ===== External Dependencies =====
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // ===== Core =====
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ===== Data - Services =====
  sl.registerLazySingleton<ApiService>(() => ApiService());
  sl.registerLazySingleton<AuthService>(() => AuthService(firebaseAuth: sl()));
  sl.registerLazySingleton<StorageService>(() => StorageService(sl()));

  // ===== Data - Repositories =====
  sl.registerLazySingleton<UserRepository>(() => UserRepository(sl(), sl()));
  sl.registerLazySingleton<SessionRepository>(() => SessionRepository(sl()));

  // ===== BLoCs/Cubits =====
  // Use factory for Cubits so each screen gets a new instance
  sl.registerFactory<UserCubit>(() => UserCubit(sl()));
  sl.registerFactory<SessionCubit>(() => SessionCubit(sl()));
}

