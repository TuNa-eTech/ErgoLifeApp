# Refactoring DI - Constructor Injection Pattern

## Tổng Quan
Đã refactor toàn bộ app để loại bỏ các direct GetIt calls (`sl<>`) từ views/screens, thay vào đó sử dụng **Constructor Injection** pattern.

## Các Thay Đổi

### ✅ Screens Đã Refactor

1. **HomeScreen** (`home_screen.dart`)
   - ❌ Trước: `create: (_) => sl<HomeBloc>()`  
   - ✅ Sau: Nhận `homeBloc` qua constructor

2. **TasksScreen** (`tasks_screen.dart`)
   - ❌ Trước: `create: (_) => sl<TasksBloc>()`
   - ✅ Sau: Nhận `tasksBloc` qua constructor

3. **CreateTaskScreen** (`create_task_screen.dart`)
   - ❌ Trước: `create: (_) => sl<TaskBloc>()`
   - ✅ Sau: Nhận `taskBloc` qua constructor

4. **RankScreen** (`rank_screen.dart`)
   - ❌ Trước: `create: (_) => sl<LeaderboardBloc>()`
   - ✅ Sau: Nhận `leaderboardBloc` qua constructor

5. **ProfileScreen** (`profile_screen.dart`)
   - ❌ Trước: `create: (_) => sl<ProfileBloc>()`
   - ✅ Sau: Nhận `profileBloc` qua constructor

6. **RewardsScreen** (`rewards_screen.dart`)
   - ❌ Trước: `create: (_) => sl<RewardsBloc>()`
   - ✅ Sau: Nhận `rewardsBloc` qua constructor

7. **OnboardingScreen** (`onboarding_screen.dart`)
   - ❌ Trước: `_onboardingBloc = widget.bloc ?? sl<OnboardingBloc>()`
   - ✅ Sau: Nhận `onboardingBloc` qua constructor (required)

### 📋 Router Updates (`app_router.dart`)

**Router giờ chịu trách nhiệm inject BLoCs:**

```dart
// Example: HomeScreen
pageBuilder: (context, state) => NoTransitionPage(
  child: HomeScreen(homeBloc: sl<HomeBloc>()),
),

// Example: TasksScreen  
pageBuilder: (context, state) => NoTransitionPage(
  child: TasksScreen(tasksBloc: sl<TasksBloc>()),
),
```

**Lợi ích:**
- ✅ Screens không biết về DI container
- ✅ Dễ test (inject mock BLoCs)
- ✅ Rõ ràng về dependencies
- ✅ Tuân thủ SOLID principles

### 🔧 Fixed Files

**Updated imports:**
- Removed `import 'package:ergo_life_app/core/di/service_locator.dart'` từ tất cả screens
- Added BLoC imports vào `app_router.dart`

**Test fixes:**
- `onboarding_screen_test.dart`: Updated parameter name `bloc` → `onboardingBloc`

### 📊 Impact Summary

| File | Changes | Lines Changed |
|------|---------|---------------|
| home_screen.dart | Constructor injection | ~10 |
| tasks_screen.dart | Constructor injection | ~10 |
| create_task_screen.dart | Constructor injection | ~10 |
| rank_screen.dart | Constructor injection | ~10 |
| profile_screen.dart | Constructor injection | ~10 |
| rewards_screen.dart | Constructor injection | ~10 |
| onboarding_screen.dart | Required parameter | ~5 |
| app_router.dart | Inject all BLoCs | ~30 |
| onboarding_screen_test.dart | Fix parameter name | ~2 |

**Total:** ~100 lines changed

## Kết Quả

✅ **0 direct GetIt calls trong views**  
✅ **Tất cả BLoCs được inject qua constructor**  
✅ **Router quản lý lifecycle của BLoCs**  
✅ **Dễ dàng test với mock BLoCs**  
✅ **Code sạch hơn, maintainable hơn**

## Note

**AuthBloc vẫn được inject ở router level** vì nó là singleton và được share across app:
- `SplashScreen(authBloc: sl<AuthBloc>())`
- `LoginScreen(authBloc: sl<AuthBloc>())`

Điều này là hợp lý vì AuthBloc cần persist state trong suốt app lifecycle.
