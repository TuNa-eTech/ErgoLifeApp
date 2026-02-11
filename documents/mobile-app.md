# Mobile App — Flutter

## Tech Stack

| Component | Công nghệ |
|-----------|-----------|
| Framework | Flutter 3.35+ (via FVM) |
| Language | Dart |
| State Management | flutter_bloc |
| Navigation | go_router |
| DI | get_it |
| Error Handling | dartz (Either) |
| HTTP | dio (ApiClient) |
| Animations | flutter_staggered_animations, Lottie |
| Push | Firebase Cloud Messaging |
| Auth | Firebase Auth (Google/Apple) |

---

## Kiến trúc

### Clean Architecture (3 layers)

```
┌─────────────────────────────────────┐
│           UI Layer                  │
│  Screens → Widgets → Theme         │
└──────────────┬──────────────────────┘
               │ BlocBuilder / BlocConsumer
┌──────────────▼──────────────────────┐
│        Business Logic (BLoC)        │
│  Events → Bloc → States            │
└──────────────┬──────────────────────┘
               │ Repository calls
┌──────────────▼──────────────────────┐
│          Data Layer                 │
│  Repository → ApiClient → Models   │
└─────────────────────────────────────┘
```

### Luồng dữ liệu

1. **UI** dispatch `Event` vào `Bloc`
2. **Bloc** gọi `Repository` method
3. **Repository** gọi API qua `ApiClient`, trả về `Either<Failure, Data>`
4. **Bloc** emit `State` mới (success / error)
5. **UI** rebuild với `BlocBuilder`

---

## Cấu trúc thư mục

```
lib/
├── blocs/                   # Business Logic Components
│   ├── auth/                # AuthBloc (login, logout, session)
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   ├── home/                # HomeBloc (dashboard data)
│   ├── tasks/               # TasksBloc (CRUD tasks)
│   ├── gifts/               # GiftsBloc (catalog, send, history)
│   └── notification/        # NotificationBloc
│
├── core/
│   ├── config/
│   │   └── theme_config.dart    # AppColors, Light/Dark themes
│   ├── constants/
│   │   └── api_constants.dart   # API endpoint paths
│   ├── di/
│   │   └── service_locator.dart # GetIt registration
│   └── navigation/
│       └── app_router.dart      # GoRouter configuration
│
├── data/
│   ├── models/              # fromJson / toJson data classes
│   ├── repositories/        # API interaction (Either pattern)
│   └── services/            # ApiClient, AuthService
│
└── ui/
    ├── screens/             # 17 screen folders
    │   ├── auth/            # Login screen
    │   ├── home/            # Home + widgets (arena, stats, tasks)
    │   ├── tasks/           # Task grid, active session, magic wipe
    │   ├── gifts/           # Gift catalog + history
    │   ├── notifications/   # Notification center
    │   ├── profile/         # Profile + edit
    │   ├── leaderboard/     # Monthly leaderboard
    │   ├── house/           # House management
    │   ├── onboarding/      # Profile setup, avatar, house
    │   ├── welcome/         # App introduction
    │   ├── rewards/         # Reward shop
    │   └── ...
    └── widgets/             # Shared components
```

---

## Navigation (GoRouter)

### Bottom Navigation (StatefulShellRoute)

| Tab | Route | Screen |
|-----|-------|--------|
| 🏠 Home | `/` | HomeScreen |
| 📋 Tasks | `/tasks` | TasksScreen |
| 🏆 Rank | `/rank` | RankScreen |
| 👤 Profile | `/profile` | ProfileScreen |

### Other Routes

| Route | Screen | Mô tả |
|-------|--------|--------|
| `/splash` | SplashScreen | Khởi động |
| `/welcome` | WelcomeScreen | Giới thiệu |
| `/onboarding` | OnboardingScreen | Setup |
| `/login` | LoginScreen | Đăng nhập |
| `/active-session` | ActiveSessionScreen | Timer |
| `/leaderboard` | LeaderboardScreen | Xếp hạng |
| `/profile/edit` | EditProfileScreen | Chỉnh sửa |
| `/house/*` | House screens | Quản lý nhà |
| `/notifications` | NotificationCenter | Thông báo |
| `/gifts` | GiftsScreen | Quà tặng |
| `/gifts/history` | GiftHistoryScreen | Lịch sử quà |

---

## Design System

### Bảng màu (AppColors)

| Tên | Hex | Vai trò |
|-----|-----|---------|
| `primary` | `#0D59F2` | Electric Blue — Accent chính |
| `primaryDark` | `#0A47C2` | Blue đậm hơn |
| `secondary` | `#FF6B00` | Vibrant Orange — CTA, badges |
| `backgroundLight` | `#F5F6F8` | Nền sáng |
| `backgroundDark` | `#0F1115` | Nền tối |
| `surfaceLight` | `#FFFFFF` | Card sáng |
| `surfaceDark` | `#1A1D24` | Card tối |
| `success` | `#10B981` | Thành công |
| `warning` | `#F59E0B` | Cảnh báo |
| `error` | `#EF4444` | Lỗi |
| `purple` | `#8B5CF6` | Task card accent |
| `pink` | `#EC4899` | Task card accent |

### Design Patterns

| Pattern | Chi tiết |
|---------|---------|
| Card radius | `borderRadius(20-24)` |
| Card background | `surfaceDark` / `surfaceLight` |
| Card border | `grey.shade800` (dark) / `grey.shade200` (light) |
| Decorative circles | `primary/secondary.withOpacity(0.08)` |
| Section headers | Uppercase, `letterSpacing: 1.5-2`, `fontSize: 10-11` |
| List animations | `flutter_staggered_animations` slide + fade |
| Theme check | `final isDark = Theme.of(context).brightness == Brightness.dark` |

---

## Dependency Injection

Đăng ký tại `core/di/service_locator.dart`:

```
Services     → Singleton (ApiClient, AuthService)
Repositories → Lazy Singleton (GiftRepository, RewardRepository, ...)
BLoCs        → Factory (GiftsBloc, TasksBloc, ...)
```

---

## Key Packages

| Package | Vai trò |
|---------|---------|
| `flutter_bloc` | State management |
| `go_router` | Declarative navigation |
| `get_it` | Dependency injection |
| `dartz` | Functional programming (Either) |
| `dio` | HTTP client |
| `firebase_auth` | Google/Apple auth |
| `firebase_messaging` | Push notifications |
| `flutter_staggered_animations` | List/grid animations |
| `lottie` | Ergo-Coach animations |
| `wakelock_plus` | Keep screen on |
| `flutter_gen` | Asset generation |
