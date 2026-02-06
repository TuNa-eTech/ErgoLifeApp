# Clean Architecture for Flutter

## Overview

This project follows a **simplified Clean Architecture** pattern, organizing code into distinct layers with clear responsibilities and dependencies flowing inward.

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── firebase_options.dart     # Firebase config
│
├── core/                     # Shared infrastructure
│   ├── config/               # App configuration
│   │   ├── app_config.dart
│   │   └── theme_config.dart
│   ├── constants/            # App-wide constants
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── di/                   # Dependency injection
│   │   └── service_locator.dart
│   ├── errors/               # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── navigation/           # Routing
│   │   └── app_router.dart
│   ├── network/              # HTTP client, interceptors
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   └── utils/                # Helpers, extensions, logger
│       ├── extensions.dart
│       └── logger.dart
│
├── data/                     # Data layer
│   ├── models/               # Data Transfer Objects (DTOs)
│   │   ├── user_model.dart
│   │   ├── task_model.dart
│   │   └── ...
│   ├── repositories/         # Repository implementations
│   │   ├── user_repository.dart
│   │   ├── auth_repository.dart
│   │   └── ...
│   └── services/             # External services
│       ├── auth_service.dart
│       └── storage_service.dart
│
├── blocs/                    # Business Logic (Presentation layer)
│   ├── auth/
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   ├── home/
│   │   ├── home_bloc.dart
│   │   ├── home_event.dart
│   │   └── home_state.dart
│   └── ...
│
├── ui/                       # UI layer
│   ├── screens/              # Full-page screens
│   │   ├── auth/
│   │   ├── home/
│   │   └── ...
│   ├── widgets/              # Reusable widgets
│   │   ├── buttons/
│   │   ├── cards/
│   │   └── ...
│   └── common/               # Shared UI components
│       ├── app_bar.dart
│       └── loading.dart
│
└── l10n/                     # Localization
    ├── app_localizations.dart
    ├── app_en.arb
    └── app_vi.arb
```

## Layer Responsibilities

### Core Layer (`core/`)
Infrastructure & shared utilities used across all layers.

| Folder | Responsibility |
|--------|----------------|
| `config/` | Environment configuration, theme settings |
| `constants/` | API endpoints, app-wide constants |
| `di/` | Service locator (GetIt) setup |
| `errors/` | Exception & Failure classes |
| `navigation/` | GoRouter configuration |
| `network/` | API client, interceptors, network info |
| `utils/` | Logger, extensions, validators |

### Data Layer (`data/`)
Data access & external services.

| Folder | Responsibility |
|--------|----------------|
| `models/` | DTOs with `fromJson`/`toJson` methods |
| `repositories/` | Data orchestration, caching, error handling |
| `services/` | External services (Firebase Auth, Storage) |

### Business Logic Layer (`blocs/`)
Application state management using BLoC pattern.

| Component | Responsibility |
|-----------|----------------|
| `*_bloc.dart` | Event handling, state transitions |
| `*_event.dart` | User actions, system events |
| `*_state.dart` | UI state representations |

### UI Layer (`ui/`)
Presentation components.

| Folder | Responsibility |
|--------|----------------|
| `screens/` | Full-page widgets with BlocProvider |
| `widgets/` | Reusable, stateless UI components |
| `common/` | Shared UI elements (app bars, dialogs) |

## Dependency Flow

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                            │
│  (screens, widgets)                                         │
└─────────────────────────┬───────────────────────────────────┘
                          │ uses
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                     │
│  (BLoCs, Cubits)                                            │
└─────────────────────────┬───────────────────────────────────┘
                          │ uses
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                            │
│  (Repositories, Services, Models)                           │
└─────────────────────────┬───────────────────────────────────┘
                          │ uses
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                       Core Layer                            │
│  (Network, Errors, Constants, Utils)                        │
└─────────────────────────────────────────────────────────────┘
```

## Key Patterns

### 1. Repository Pattern

Repositories orchestrate data from multiple sources and handle caching.

```dart
// data/repositories/user_repository.dart
class UserRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  UserRepository(this._apiClient, this._storageService);

  // ===== API Methods =====
  
  Future<Either<Failure, UserModel>> updateProfile({
    String? displayName,
    int? avatarId,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.usersMe,
        data: {'displayName': displayName, 'avatarId': avatarId},
      );
      final userData = _apiClient.unwrapResponse(response.data);
      return Right(UserModel.fromJson(userData));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: 'Unable to connect'));
    }
  }

  // ===== Cache Methods =====
  
  UserModel? getCachedUser() {
    final jsonString = _storageService.getString(AppConstants.keyUserProfile);
    return jsonString != null ? UserModel.fromJsonString(jsonString) : null;
  }

  Future<bool> cacheUser(UserModel user) async {
    return await _storageService.saveString(
      AppConstants.keyUserProfile,
      user.toJsonString(),
    );
  }
}
```

### 2. Error Handling with Either

Use `dartz` package for functional error handling.

```dart
// core/errors/failures.dart
abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
```

```dart
// Usage in BLoC
final result = await _userRepository.updateProfile(displayName: 'John');

result.fold(
  (failure) => emit(ProfileError(message: failure.message)),
  (user) => emit(ProfileLoaded(user: user)),
);
```

### 3. Model (DTO) Pattern

Models handle JSON serialization with Equatable for comparison.

```dart
// data/models/user_model.dart
class UserModel extends Equatable {
  final String id;
  final String firebaseUid;
  final String? email;
  final String? name;
  final int walletBalance;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    this.email,
    this.name,
    this.walletBalance = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      firebaseUid: json['firebaseUid'] as String? ?? '',
      email: json['email'] as String?,
      name: json['displayName'] as String?,
      walletBalance: json['walletBalance'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firebaseUid': firebaseUid,
    'email': email,
    'name': name,
    'walletBalance': walletBalance,
  };

  String toJsonString() => json.encode(toJson());

  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(json.decode(jsonString));
  }

  UserModel copyWith({...}) => UserModel(...);

  @override
  List<Object?> get props => [id, firebaseUid, email, name, walletBalance];
}
```

### 4. BLoC Pattern

Separate Events, States, and Bloc logic.

```dart
// blocs/home/home_event.dart
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}
```

```dart
// blocs/home/home_state.dart
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final UserModel user;
  final WeeklyStats stats;
  final List<TaskModel> quickTasks;

  const HomeLoaded({
    required this.user,
    required this.stats,
    required this.quickTasks,
  });

  @override
  List<Object?> get props => [user, stats, quickTasks];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
```

```dart
// blocs/home/home_bloc.dart
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthRepository _authRepository;
  final ActivityRepository _activityRepository;
  final TaskRepository _taskRepository;

  HomeBloc({
    required AuthRepository authRepository,
    required ActivityRepository activityRepository,
    required TaskRepository taskRepository,
  }) : _authRepository = authRepository,
       _activityRepository = activityRepository,
       _taskRepository = taskRepository,
       super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    try {
      final userResult = await _authRepository.getCurrentUser();

      userResult.fold(
        (failure) => emit(HomeError(message: failure.message)),
        (user) async {
          final statsResult = await _activityRepository.getStats(period: 'week');
          final stats = statsResult.fold((_) => WeeklyStats.empty(), (s) => s);

          final tasksResult = await _taskRepository.getTasks();
          final tasks = tasksResult.fold((_) => <TaskModel>[], (t) => t);

          emit(HomeLoaded(user: user, stats: stats, quickTasks: tasks));
        },
      );
    } catch (e) {
      emit(const HomeError(message: 'Failed to load home data'));
    }
  }
}
```

## Service Locator Setup

```dart
// core/di/service_locator.dart
final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ===== External Dependencies =====
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  
  // ===== Core =====
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // ===== Services =====
  sl.registerLazySingleton<StorageService>(() => StorageService(sl()));
  sl.registerSingletonAsync<AuthService>(() async {
    final service = AuthService(firebaseAuth: sl());
    await service.initialize();
    return service;
  });
  
  // ===== Repositories =====
  sl.registerLazySingleton<UserRepository>(() => UserRepository(sl(), sl()));
  sl.registerSingletonWithDependencies<AuthRepository>(
    () => AuthRepository(sl(), sl(), sl()),
    dependsOn: [AuthService],
  );
  
  // ===== BLoCs =====
  sl.registerFactory<HomeBloc>(() => HomeBloc(
    authRepository: sl(),
    activityRepository: sl(),
    taskRepository: sl(),
  ));
}
```

## Best Practices

### DO ✅
- Keep each layer focused on its responsibility
- Use `Either<Failure, T>` for repository methods
- Inject repositories into BLoCs via constructor
- Use factories for BLoCs (fresh instance per screen)
- Use lazy singletons for repositories and services
- Extend `Equatable` for Models, States, Events
- Group constants in dedicated files

### DON'T ❌
- Don't access repositories directly from UI
- Don't put business logic in widgets
- Don't use singletons for BLoCs (causes state issues)
- Don't skip error handling in repositories
- Don't call APIs directly from BLoCs (use repositories)

## Adding a New Feature

1. **Create Model** in `data/models/`
   ```dart
   class NewFeatureModel extends Equatable { ... }
   ```

2. **Create Repository** in `data/repositories/`
   ```dart
   class NewFeatureRepository {
     Future<Either<Failure, NewFeatureModel>> getData() async { ... }
   }
   ```

3. **Create BLoC** in `blocs/new_feature/`
   ```
   blocs/new_feature/
   ├── new_feature_bloc.dart
   ├── new_feature_event.dart
   └── new_feature_state.dart
   ```

4. **Register in Service Locator**
   ```dart
   sl.registerLazySingleton<NewFeatureRepository>(() => NewFeatureRepository(sl()));
   sl.registerFactory<NewFeatureBloc>(() => NewFeatureBloc(sl()));
   ```

5. **Create Screen** in `ui/screens/new_feature/`

6. **Add Route** in `core/navigation/app_router.dart`
