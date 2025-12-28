import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:ergo_life_app/core/network/network_info.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/core/config/app_config.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

// Data - Services
import 'package:ergo_life_app/data/services/api_service.dart';
import 'package:ergo_life_app/data/services/auth_service.dart';
import 'package:ergo_life_app/data/services/storage_service.dart';

// Data - Repositories
import 'package:ergo_life_app/data/repositories/user_repository.dart';
import 'package:ergo_life_app/data/repositories/session_repository.dart';
import 'package:ergo_life_app/data/repositories/auth_repository.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';
import 'package:ergo_life_app/data/repositories/house_repository.dart';

// BLoCs/Cubits
import 'package:ergo_life_app/blocs/user/user_cubit.dart';
import 'package:ergo_life_app/blocs/auth/auth_bloc.dart';
import 'package:ergo_life_app/blocs/home/home_bloc.dart';
import 'package:ergo_life_app/blocs/session/session_bloc.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_bloc.dart';
import 'package:ergo_life_app/blocs/profile/profile_bloc.dart';
import 'package:ergo_life_app/blocs/house/house_bloc.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_bloc.dart';
import 'package:ergo_life_app/data/repositories/reward_repository.dart';
import 'package:ergo_life_app/blocs/rewards/rewards_bloc.dart';
import 'package:ergo_life_app/blocs/task/task_bloc.dart';

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
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Register AuthService asynchronously to wait for Google Sign-In initialization
  sl.registerSingletonAsync<AuthService>(() async {
    final authService = AuthService(firebaseAuth: sl());
    // Initialize Google Sign-In with client ID from environment
    if (AppConfig.googleClientId.isNotEmpty) {
      AppLogger.info(
        'Initializing Google Sign-In with clientId: ${AppConfig.googleClientId.substring(0, 20)}...',
        'ServiceLocator',
      );
      await authService.initializeGoogleSignIn(clientId: AppConfig.googleClientId);
      AppLogger.success('Google Sign-In initialized', 'ServiceLocator');
    } else {
      AppLogger.warning('Google Client ID is empty, skipping Google Sign-In initialization', 'ServiceLocator');
    }
    return authService;
  });
  
  sl.registerLazySingleton<StorageService>(() => StorageService(sl()));

  // ===== Data - Repositories =====
  sl.registerLazySingleton<UserRepository>(() => UserRepository(sl(), sl()));
  sl.registerLazySingleton<SessionRepository>(() => SessionRepository(sl()));
  sl.registerLazySingleton<ActivityRepository>(() => ActivityRepository(sl()));
  sl.registerLazySingleton<HouseRepository>(() => HouseRepository(sl()));
  sl.registerLazySingleton<RewardRepository>(() => RewardRepository(sl()));
  
  // AuthRepository depends on async AuthService, so must wait for it
  sl.registerSingletonWithDependencies<AuthRepository>(
    () => AuthRepository(sl(), sl(), sl()),
    dependsOn: [AuthService],
  );

  // ===== BLoCs/Cubits =====
  // AuthBloc depends on async AuthRepository, so must wait for it
  sl.registerSingletonWithDependencies<AuthBloc>(
    () => AuthBloc(sl()),
    dependsOn: [AuthRepository],
  );

  // Use factory for other BLoCs so each screen gets a new instance
  sl.registerFactory<UserCubit>(() => UserCubit(sl()));

  // HomeBloc - factory because each home screen instance should have own state
  sl.registerFactory<HomeBloc>(() => HomeBloc(
        authRepository: sl(),
        activityRepository: sl(),
        houseRepository: sl(),
      ));

  // SessionBloc - singleton because session state should persist across screens
  sl.registerLazySingleton<SessionBloc>(
    () => SessionBloc(activityRepository: sl()),
  );

  // LeaderboardBloc - factory for fresh data each time
  sl.registerFactory<LeaderboardBloc>(() => LeaderboardBloc(
        activityRepository: sl(),
        storageService: sl(),
      ));

  // TasksBloc - factory for independent instances
  sl.registerFactory<TasksBloc>(
    () => TasksBloc(activityRepository: sl()),
  );

  // TaskBloc - factory for custom task management
  sl.registerFactory<TaskBloc>(
    () => TaskBloc(sl()),
  );

  // ProfileBloc - factory for fresh data each time
  sl.registerFactory<ProfileBloc>(() => ProfileBloc(
        authRepository: sl(),
        activityRepository: sl(),
        apiService: sl(),
      ));

  // HouseBloc - factory for independent instances
  sl.registerFactory<HouseBloc>(() => HouseBloc(houseRepository: sl()));

  // OnboardingBloc - factory for fresh onboarding state
  sl.registerFactory<OnboardingBloc>(() => OnboardingBloc(apiService: sl()));

  // RewardsBloc
  sl.registerFactory<RewardsBloc>(() => RewardsBloc(
    rewardRepository: sl(),
    userRepository: sl(),
  ));
}

