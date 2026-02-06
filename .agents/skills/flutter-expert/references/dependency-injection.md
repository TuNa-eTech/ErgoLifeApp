# Dependency Injection with GetIt

## Overview

GetIt is a simple service locator for Dart and Flutter projects. It provides a way to access services from anywhere in your app without passing them through constructors.

## Installation

```yaml
dependencies:
  get_it: ^8.0.0
```

## Project Structure

```
lib/
├── core/
│   └── di/
│       └── service_locator.dart    # Main DI configuration
├── data/
│   ├── services/                   # External services (Auth, Storage, etc.)
│   └── repositories/               # Data access layer
├── blocs/                          # BLoCs and Cubits
└── main.dart                       # Entry point
```

## Basic Setup

### 1. Create Service Locator

```dart
// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ===== External Dependencies =====
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  
  // ===== Core =====
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // ===== Services =====
  sl.registerSingletonAsync<AuthService>(() async {
    final authService = AuthService(firebaseAuth: sl());
    await authService.initialize();
    return authService;
  });
  
  sl.registerLazySingleton<StorageService>(() => StorageService(sl()));
  
  // ===== Repositories =====
  sl.registerLazySingleton<UserRepository>(() => UserRepository(sl(), sl()));
  sl.registerLazySingleton<SessionRepository>(() => SessionRepository(sl()));
  
  // Repository với async dependency
  sl.registerSingletonWithDependencies<AuthRepository>(
    () => AuthRepository(sl(), sl(), sl()),
    dependsOn: [AuthService],
  );
  
  // ===== BLoCs/Cubits =====
  // Singleton Bloc với async dependency
  sl.registerSingletonWithDependencies<AuthBloc>(
    () => AuthBloc(sl()),
    dependsOn: [AuthRepository],
  );
  
  // Factory cho các Bloc khác - mỗi screen có instance riêng
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      authRepository: sl(),
      activityRepository: sl(),
      houseRepository: sl(),
    ),
  );
  
  sl.registerFactory<SessionBloc>(() => SessionBloc(activityRepository: sl()));
  
  // Lazy singleton cho shared state
  sl.registerLazySingleton<HouseBloc>(() => HouseBloc(houseRepository: sl()));
}
```

### 2. Initialize in main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Setup service locator
  await setupServiceLocator();
  
  // Wait for all async dependencies to be ready
  await sl.allReady();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HouseBloc>()..add(const LoadHouse())),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 3. Access Dependencies

**Inject qua constructor** - Pattern được khuyến nghị cho screens/widgets:

```dart
// Screen nhận Bloc qua constructor
class HomeScreen extends StatelessWidget {
  final HomeBloc homeBloc;
  
  const HomeScreen({super.key, required this.homeBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: homeBloc..add(const LoadHomeData()),
      child: const HomeView(),
    );
  }
}

// Router tạo và inject Bloc
GoRoute(
  path: '/home',
  builder: (context, state) => HomeScreen(homeBloc: sl<HomeBloc>()),
),

// Với extra parameters
GoRoute(
  path: '/session',
  builder: (context, state) {
    final task = state.extra as Task;
    return ActiveSessionScreen(
      sessionBloc: sl<SessionBloc>()..add(PrepareSession(task: task)),
    );
  },
),
```

**Direct access** - Chỉ dùng cho cross-bloc communication:

```dart
// Trigger refresh từ một screen (singleton blocs only)
void onSessionComplete() {
  sl<HomeBloc>().add(const RefreshHomeData());
  sl<LeaderboardBloc>().add(const RefreshLeaderboard());
}

## Registration Types

### Lazy Singleton
Created on first access, then same instance. **Use for stateless services and repositories.**

```dart
sl.registerLazySingleton<ApiClient>(() => ApiClient());
sl.registerLazySingleton<UserRepository>(() => UserRepository(sl(), sl()));
```

### Singleton
Same instance throughout app lifetime.

```dart
// Eager - created immediately
sl.registerSingleton<AppConfig>(AppConfig());

// Async singleton - cần khởi tạo bất đồng bộ
sl.registerSingletonAsync<AuthService>(() async {
  final service = AuthService(firebaseAuth: sl());
  await service.initialize();
  return service;
});

// Singleton with dependencies - đợi các dependency async
sl.registerSingletonWithDependencies<AuthRepository>(
  () => AuthRepository(sl(), sl(), sl()),
  dependsOn: [AuthService],
);

sl.registerSingletonWithDependencies<AuthBloc>(
  () => AuthBloc(sl()),
  dependsOn: [AuthRepository],
);
```

### Factory
New instance every time. **Use for BLoCs/Cubits to ensure fresh state per screen.**

```dart
// Simple factory
sl.registerFactory<HomeBloc>(
  () => HomeBloc(
    authRepository: sl(),
    activityRepository: sl(),
    houseRepository: sl(),
  ),
);

// Factory with typed parameter
sl.registerFactoryParam<ProductDetailBloc, String, void>(
  (productId, _) => ProductDetailBloc(
    productId: productId,
    repository: sl<ProductRepository>(),
  ),
);

// Usage
final bloc = sl<ProductDetailBloc>(param1: 'product-123');
```

## When to Use Each Type

| Type | Use Case | Example |
|------|----------|---------|
| **Lazy Singleton** | Stateless services, repositories, API clients | `ApiClient`, `UserRepository`, `StorageService` |
| **Singleton** | App-wide configuration, Firebase instances | `AppConfig`, `FirebaseAuth.instance` |
| **Async Singleton** | Services cần khởi tạo bất đồng bộ | `SharedPreferences`, `AuthService` (Google Sign-In) |
| **Singleton with Dependencies** | Phụ thuộc vào async singleton | `AuthRepository`, `AuthBloc` |
| **Factory** | BLoCs/Cubits - mỗi screen cần instance mới | `HomeBloc`, `SessionBloc`, `ProfileBloc` |
| **Lazy Singleton (Bloc)** | BLoCs chia sẻ state giữa nhiều screens | `HouseBloc`, `ThemeBloc` |

## Dependency Resolution

GetIt sử dụng `sl()` để tự động resolve type:

```dart
// Explicit type
sl.registerLazySingleton<UserRepository>(() => UserRepository(sl(), sl()));

// sl() auto-resolves based on constructor parameter types
class UserRepository {
  final ApiClient apiClient;
  final StorageService storage;
  
  UserRepository(this.apiClient, this.storage);
}

// GetIt sẽ tự động inject ApiClient và StorageService
```

## Waiting for Async Dependencies

```dart
// Đợi tất cả async registrations hoàn thành
await sl.allReady();

// Đợi specific type
await sl.isReady<AuthService>();

// Check if ready
if (sl.isRegistered<AuthBloc>()) {
  // ...
}
```

## Best Practices

### DO ✅
- **Inject dependencies via constructor** - dễ test, rõ ràng dependencies
- **Use `sl` as service locator variable** - ngắn gọn, dễ đọc
- **Register all dependencies in one file** - `service_locator.dart`
- **Create Blocs in Router** - inject vào screen qua constructor
- **Use Lazy Singleton for services** - tạo khi cần, tái sử dụng
- **Use Factory for BLoCs** - mỗi screen có state riêng
- **Use Singleton with Dependencies** cho dependency chains
- **Wait `sl.allReady()`** trước khi runApp
- **Group registrations** theo category với comments

### DON'T ❌
- **Don't use GetIt directly in widgets** - thay vào đó, inject qua constructor hoặc BlocProvider
- **Don't use Singleton for BLoCs** - gây lỗi "Cannot add events after close"
- **Don't register dependencies inside widgets**
- **Don't create circular dependencies**
- **Don't skip `allReady()`** khi có async dependencies

## Testing with GetIt

```dart
void main() {
  setUp(() {
    // Reset GetIt before each test
    sl.reset();
  });
  
  tearDown(() {
    sl.reset();
  });
  
  test('should login user', () async {
    // Register mocks
    sl.registerSingleton<AuthService>(MockAuthService());
    sl.registerSingleton<UserRepository>(MockUserRepository());
    
    final bloc = AuthBloc(sl<AuthService>());
    // ... test
  });
}
```

### Allow Reassignment for Testing

```dart
void main() {
  setUpAll(() {
    sl.allowReassignment = true;
  });
  
  test('test with mock', () {
    sl.registerSingleton<ApiClient>(MockApiClient());
    // ... test
  });
}
```

## Common Patterns

### Router Integration (Constructor Injection)

```dart
// lib/core/navigation/app_router.dart
GoRouter get router => GoRouter(
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(homeBloc: sl<HomeBloc>()),
    ),
    GoRoute(
      path: '/session',
      builder: (context, state) {
        final task = state.extra as Task;
        return ActiveSessionScreen(
          sessionBloc: sl<SessionBloc>()..add(PrepareSession(task: task)),
        );
      },
    ),
    GoRoute(
      path: '/tasks',
      builder: (context, state) => TasksScreen(tasksBloc: sl<TasksBloc>()),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => LeaderboardScreen(
        leaderboardBloc: sl<LeaderboardBloc>(),
      ),
    ),
  ],
);

### Cross-Bloc Communication

```dart
// Trigger refresh từ một screen
void onSessionComplete() {
  sl<HomeBloc>().add(const RefreshHomeData());
  sl<LeaderboardBloc>().add(const RefreshLeaderboard());
}
```

### StatefulWidget với Constructor Injection

```dart
class ProfileScreen extends StatelessWidget {
  final ProfileBloc profileBloc;
  
  const ProfileScreen({super.key, required this.profileBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: profileBloc..add(const LoadProfile()),
      child: const ProfileView(),
    );
  }
}

// Trong router
GoRoute(
  path: '/profile',
  builder: (context, state) => ProfileScreen(profileBloc: sl<ProfileBloc>()),
),
```

### Multiple Blocs via Constructor

```dart
class DashboardScreen extends StatelessWidget {
  final HomeBloc homeBloc;
  final LeaderboardBloc leaderboardBloc;
  
  const DashboardScreen({
    super.key,
    required this.homeBloc,
    required this.leaderboardBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: homeBloc),
        BlocProvider.value(value: leaderboardBloc),
      ],
      child: const DashboardView(),
    );
  }
}

// Router
GoRoute(
  path: '/dashboard',
  builder: (context, state) => DashboardScreen(
    homeBloc: sl<HomeBloc>()..add(const LoadHomeData()),
    leaderboardBloc: sl<LeaderboardBloc>()..add(const LoadLeaderboard()),
  ),
),
```
