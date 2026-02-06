# Project Structure

## ErgoLifeApp Structure

```
lib/
├── main.dart                 # Entry point
├── firebase_options.dart     # Firebase config
│
├── core/                     # Shared infrastructure
│   ├── config/               # App & theme configuration
│   ├── constants/            # API endpoints, app constants
│   ├── di/                   # Service locator (GetIt)
│   │   └── service_locator.dart
│   ├── errors/               # Exceptions & Failures
│   ├── navigation/           # GoRouter configuration
│   │   └── app_router.dart
│   ├── network/              # API client, interceptors
│   └── utils/                # Logger, extensions, helpers
│
├── data/                     # Data layer
│   ├── models/               # DTOs (fromJson/toJson)
│   ├── repositories/         # Data orchestration & caching
│   └── services/             # External services (Auth, Storage)
│
├── blocs/                    # Business logic
│   ├── auth/                 # Each feature has:
│   │   ├── auth_bloc.dart    #   - *_bloc.dart
│   │   ├── auth_event.dart   #   - *_event.dart
│   │   └── auth_state.dart   #   - *_state.dart
│   ├── home/
│   ├── house/
│   ├── profile/
│   ├── tasks/
│   └── ...
│
├── ui/                       # Presentation layer
│   ├── screens/              # Full-page screens by feature
│   │   ├── auth/
│   │   ├── home/
│   │   ├── tasks/
│   │   └── ...
│   ├── widgets/              # Reusable widgets
│   └── common/               # Shared UI components
│
└── l10n/                     # Localization
    ├── app_localizations.dart
    ├── app_en.arb
    └── app_vi.arb
```

## Layer Responsibilities

| Layer | Folder | Responsibility |
|-------|--------|----------------|
| **Core** | `core/` | Infrastructure, config, DI, networking, errors |
| **Data** | `data/` | Models, repositories, external services |
| **Business Logic** | `blocs/` | State management with BLoC pattern |
| **UI** | `ui/` | Screens, widgets, visual components |
| **L10n** | `l10n/` | Internationalization |

## pubspec.yaml Essentials

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.0
  equatable: ^2.0.0
  
  # Navigation
  go_router: ^14.0.0
  
  # Dependency Injection
  get_it: ^8.0.0
  
  # Networking
  dio: ^5.4.0
  connectivity_plus: ^6.0.0
  
  # Functional Programming
  dartz: ^0.10.0
  
  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  
  # Storage
  shared_preferences: ^2.2.0
  
  # Logging
  talker_flutter: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

## Main Entry Point

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Setup service locator
  await setupServiceLocator();
  
  // Wait for all async dependencies
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ErgoLife',
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      routerConfig: AppRouter.router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

## Feature-Based Organization

Each feature follows consistent structure:

```
blocs/home/
├── home_bloc.dart      # Event handlers, state transitions
├── home_event.dart     # User actions (LoadHomeData, RefreshHomeData)
└── home_state.dart     # UI states (HomeInitial, HomeLoading, HomeLoaded, HomeError)

ui/screens/home/
├── home_screen.dart    # Screen with BlocProvider
└── widgets/            # Feature-specific widgets
    ├── stats_card.dart
    └── quick_tasks.dart
```

## File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Model | `*_model.dart` | `user_model.dart` |
| Repository | `*_repository.dart` | `user_repository.dart` |
| Service | `*_service.dart` | `auth_service.dart` |
| BLoC | `*_bloc.dart` | `home_bloc.dart` |
| Event | `*_event.dart` | `home_event.dart` |
| State | `*_state.dart` | `home_state.dart` |
| Screen | `*_screen.dart` | `home_screen.dart` |
| Widget | `*_widget.dart` or descriptive | `stats_card.dart` |

## Adding New Feature Checklist

1. ☐ Create model in `data/models/`
2. ☐ Create repository in `data/repositories/`
3. ☐ Create BLoC files in `blocs/feature_name/`
4. ☐ Register in `core/di/service_locator.dart`
5. ☐ Create screen in `ui/screens/feature_name/`
6. ☐ Add route in `core/navigation/app_router.dart`
7. ☐ Add localization strings in `l10n/`
