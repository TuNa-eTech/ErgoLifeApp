# ErgoLife App - Flutter Project Structure

## 📁 Cấu Trúc Dự Án (Layer-Based Architecture)

```
lib/
├── core/                           # Core utilities và configurations
│   ├── config/                     
│   │   ├── app_config.dart        # App configuration (environment, API URLs)
│   │   └── theme_config.dart      # Theme configuration (light/dark themes)
│   ├── constants/
│   │   ├── api_constants.dart     # API endpoints
│   │   └── app_constants.dart     # App-wide constants
│   ├── di/
│   │   └── service_locator.dart   # GetIt dependency injection setup
│   ├── errors/
│   │   ├── exceptions.dart        # Exception classes
│   │   └── failures.dart          # Failure classes
│   ├── navigation/
│   │   └── app_router.dart        # GoRouter configuration
│   ├── network/
│   │   └── network_info.dart      # Network connectivity checker
│   └── utils/
│       ├── logger.dart            # Logging utility
│       └── validators.dart        # Form validators
│
├── data/                          # Data layer
│   ├── models/                    # Data models
│   │   ├── user_model.dart
│   │   └── session_model.dart
│   ├── repositories/              # Repositories (business logic)
│   │   ├── user_repository.dart
│   │   └── session_repository.dart
│   └── services/                  # External services
│       ├── api_service.dart       # HTTP API service (Dio)
│       └── storage_service.dart   # Local storage (SharedPreferences)
│
├── blocs/                         # State management (BLoC/Cubit)
│   ├── user/
│   │   └── user_cubit.dart        # User state management
│   └── session/
│       └── session_cubit.dart     # Session state management
│
├── ui/                            # UI layer
│   └── screens/                   # All screens
│       ├── home/
│       │   └── home_screen.dart
│       └── profile/
│           └── profile_screen.dart
│
└── main.dart                      # App entry point
```

## 🏗️ Kiến Trúc

### Layer-Based Architecture (Đơn giản hóa)

Thay vì Clean Architecture phức tạp với nhiều layer (domain/data/presentation), cấu trúc này sử dụng **Layer-Based** đơn giản:

1. **Core Layer**: Configurations, utilities, navigation
2. **Data Layer**: Models, repositories, services
3. **BLoC Layer**: State management (Cubit thay vì BLoC để đơn giản hơn)
4. **UI Layer**: Screens và widgets

### Ưu điểm của cấu trúc này:

✅ **Đơn giản**: Ít boilerplate code hơn 50-60% so với Clean Architecture  
✅ **Nhanh**: Phát triển feature nhanh hơn  
✅ **Dễ hiểu**: Developer mới dễ tiếp cận  
✅ **Scalable**: Vẫn có thể mở rộng khi cần  
✅ **Testable**: Vẫn dễ dàng unit test  

## 🔧 Dependencies Chính

```yaml
# State Management
flutter_bloc: ^8.1.6

# Dependency Injection
get_it: ^8.0.0

# Navigation
go_router: ^14.6.2

# Network
dio: ^5.7.0
connectivity_plus: ^6.1.0

# Storage
shared_preferences: ^2.3.3

# Utilities
equatable: ^2.0.7
dartz: ^0.10.1
```

## 📝 Workflow Thêm Feature Mới

### Ví dụ: Thêm feature "Settings"

1. **Tạo Model** (nếu cần):
   ```dart
   // lib/data/models/settings_model.dart
   class SettingsModel extends Equatable { ... }
   ```

2. **Tạo Repository**:
   ```dart
   // lib/data/repositories/settings_repository.dart
   class SettingsRepository {
     final StorageService _storage;
     // Business logic here
   }
   ```

3. **Tạo Cubit**:
   ```dart
   // lib/blocs/settings/settings_cubit.dart
   class SettingsCubit extends Cubit<SettingsState> { ... }
   ```

4. **Tạo Screen**:
   ```dart
   // lib/ui/screens/settings/settings_screen.dart
   class SettingsScreen extends StatelessWidget { ... }
   ```

5. **Register Dependencies**:
   ```dart
   // lib/core/di/service_locator.dart
   sl.registerLazySingleton(() => SettingsRepository(sl()));
   sl.registerFactory(() => SettingsCubit(sl()));
   ```

6. **Add Route**:
   ```dart
   // lib/core/navigation/app_router.dart
   GoRoute(path: '/settings', builder: (_, __) => SettingsScreen())
   ```

**Chỉ 6 bước!** So với Clean Architecture cần 10-15 bước.

## 🎯 Best Practices

### 1. Repository Pattern
Repositories chứa business logic và handle caching:
```dart
class UserRepository {
  // Try cache first, then API
  Future<UserModel> getUser() async {
    final cached = _storage.getCachedUser();
    if (cached != null) return cached;
    
    final user = await _api.fetchUser();
    await _storage.cacheUser(user);
    return user;
  }
}
```

### 2. Cubit over BLoC
Sử dụng Cubit thay vì BLoC cho đơn giản:
```dart
// Cubit - đơn giản hơn
class UserCubit extends Cubit<UserState> {
  void loadUser() async {
    emit(UserLoading());
    final user = await _repo.getUser();
    emit(UserLoaded(user));
  }
}

// BLoC - phức tạp hơn (cần events + states)
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() {
    on<LoadUser>(_onLoadUser);
  }
  
  Future<void> _onLoadUser(LoadUser event, Emitter emit) async {
    // Same logic but more boilerplate
  }
}
```

### 3. Dependency Injection
- Lazy singleton cho Services và Repositories
- Factory cho Cubits (mỗi screen instance mới)

```dart
// Singleton - một instance cho cả app
sl.registerLazySingleton(() => ApiService());

// Factory - instance mới mỗi lần gọi
sl.registerFactory(() => UserCubit(sl()));
```

### 4. Error Handling
Sử dụng try-catch trong repositories:
```dart
Future<UserModel> getUser() async {
  try {
    return await _api.fetchUser();
  } catch (e) {
    AppLogger.error('Failed to fetch user', e);
    rethrow; // Hoặc return cached data
  }
}
```

## 🚀 Getting Started

1. **Clone và cài dependencies**:
   ```bash
   flutter pub get
   ```

2. **Chạy app**:
   ```bash
   flutter run
   ```

3. **Build**:
   ```bash
   flutter build apk --release
   ```

## 📚 Tài Liệu Tham Khảo

- [GetIt Documentation](https://pub.dev/packages/get_it)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [BLoC Documentation](https://bloclibrary.dev)
- [Flutter Best Practices](https://docs.flutter.dev/development/best-practices)

## 🎨 Roadmap

- [ ] Add more screens (Settings, Statistics)
- [ ] Implement authentication flow
- [ ] Add unit tests
- [ ] Add integration tests
- [ ] Implement CI/CD

## 📄 License

MIT License - feel free to use for your projects!
