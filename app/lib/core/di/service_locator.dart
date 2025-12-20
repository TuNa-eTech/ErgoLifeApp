import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:ergo_life_app/core/network/network_info.dart';
import 'package:ergo_life_app/core/config/app_config.dart';

// Data - Services
import 'package:ergo_life_app/data/services/api_service.dart';
import 'package:ergo_life_app/data/services/auth_service.dart';
import 'package:ergo_life_app/data/services/storage_service.dart';

// Data - Repositories
import 'package:ergo_life_app/data/repositories/user_repository.dart';
import 'package:ergo_life_app/data/repositories/session_repository.dart';
import 'package:ergo_life_app/data/repositories/auth_repository.dart';

// BLoCs/Cubits
import 'package:ergo_life_app/blocs/user/user_cubit.dart';
import 'package:ergo_life_app/blocs/session/session_cubit.dart';
import 'package:ergo_life_app/blocs/auth/auth_bloc.dart';

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
  sl.registerLazySingleton<AuthService>(() {
    final authService = AuthService(firebaseAuth: sl());
    // Initialize Google Sign-In with client ID from environment
    if (AppConfig.googleClientId.isNotEmpty) {
      authService.initializeGoogleSignIn(clientId: AppConfig.googleClientId);
    }
    return authService;
  });
  sl.registerLazySingleton<StorageService>(() => StorageService(sl()));

// Data - Repositories
  sl.registerLazySingleton<UserRepository>(() => UserRepository(sl(), sl()));
  sl.registerLazySingleton<SessionRepository>(() => SessionRepository(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl(), sl(), sl()),
  );

  // ===== BLoCs/Cubits =====
  // AuthBloc is singleton - single source of truth for auth state
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(sl()));

  // Use factory for other Cubits so each screen gets a new instance
  sl.registerFactory<UserCubit>(() => UserCubit(sl()));
  sl.registerFactory<SessionCubit>(() => SessionCubit(sl()));
}
