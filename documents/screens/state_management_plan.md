# State Management Plan - Kế Hoạch Quản Lý State

## 1. Tổng Quan

Ứng dụng ErgoLife sử dụng **BLoC pattern** (Business Logic Component) cho state management. Tài liệu này mô tả các BLoCs cần thiết, events, states, và cách tích hợp với UI.

---

## 2. Kiến Trúc State Management

### 2.1 Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     UI Layer (Screens)                       │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐            │
│  │  Home   │ │  Tasks  │ │  Rank   │ │ Profile │            │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘            │
│       │           │           │           │                  │
├───────┴───────────┴───────────┴───────────┴─────────────────┤
│                     BLoC Layer                               │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────────┐    │
│  │ AuthBloc│ │HomeBloc │ │TasksBloc│ │ LeaderboardBloc │    │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────────┬────────┘    │
│       │           │           │                │             │
├───────┴───────────┴───────────┴────────────────┴────────────┤
│                   Repository Layer                           │
│  ┌──────────────┐ ┌─────────────┐ ┌─────────────────────┐   │
│  │ AuthRepo     │ │ ActivityRepo│ │ HouseRepo           │   │
│  └──────┬───────┘ └──────┬──────┘ └──────────┬──────────┘   │
│         │                │                   │               │
├─────────┴────────────────┴───────────────────┴──────────────┤
│                   Service Layer                              │
│  ┌──────────────┐ ┌─────────────┐ ┌─────────────────────┐   │
│  │ ApiService   │ │ AuthService │ │ StorageService      │   │
│  └──────────────┘ └─────────────┘ └─────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 BLoC Providers Structure

```dart
MultiBlocProvider(
  providers: [
    // Global BLoCs
    BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
    BlocProvider<UserBloc>(create: (_) => sl<UserBloc>()),
    
    // Feature BLoCs (lazy loaded)
    BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
    BlocProvider<TasksBloc>(create: (_) => sl<TasksBloc>()),
    BlocProvider<SessionBloc>(create: (_) => sl<SessionBloc>()),
    BlocProvider<LeaderboardBloc>(create: (_) => sl<LeaderboardBloc>()),
    BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
    BlocProvider<HouseBloc>(create: (_) => sl<HouseBloc>()),
  ],
  child: MaterialApp.router(...),
)
```

---

## 3. BLoC Definitions

### 3.1 AuthBloc (Đã Có)

**Purpose:** Quản lý authentication state

```dart
// Events
abstract class AuthEvent {}
class AuthCheckRequested extends AuthEvent {}
class AuthGoogleSignInRequested extends AuthEvent {}
class AuthAppleSignInRequested extends AuthEvent {}
class AuthLogoutRequested extends AuthEvent {}
class AuthSessionExpired extends AuthEvent {}

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  final bool isNewUser;
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  final String? code;
}
```

**Screen Usage:**
| Screen | Events | States Listened |
|--------|--------|-----------------|
| Splash | `AuthCheckRequested` | `AuthAuthenticated`, `AuthUnauthenticated` |
| Login | `AuthGoogleSignInRequested`, `AuthAppleSignInRequested` | `AuthLoading`, `AuthAuthenticated`, `AuthError` |
| Profile | `AuthLogoutRequested` | `AuthUnauthenticated` |

---

### 3.2 UserBloc (Cần Implement)

**Purpose:** Quản lý user profile

```dart
// Events
abstract class UserEvent {}
class LoadUser extends UserEvent {}
class UpdateProfile extends UserEvent {
  final String? displayName;
  final int? avatarId;
}
class UpdateFcmToken extends UserEvent {
  final String token;
}

// States
abstract class UserState {}
class UserInitial extends UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  final User user;
}
class UserUpdateSuccess extends UserState {
  final User user;
}
class UserError extends UserState {
  final String message;
}
```

**Screen Usage:**
| Screen | Events | States Listened |
|--------|--------|-----------------|
| Home | `LoadUser` | `UserLoaded` |
| Onboarding | `UpdateProfile` | `UserUpdateSuccess`, `UserError` |
| Profile | `LoadUser`, `UpdateProfile` | `UserLoaded`, `UserUpdateSuccess` |

---

### 3.3 HomeBloc (Cần Implement)

**Purpose:** Quản lý data cho Home screen

```dart
// Events
abstract class HomeEvent {}
class LoadHomeData extends HomeEvent {}
class RefreshHomeData extends HomeEvent {}

// States
abstract class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final User user;
  final WeeklyStats stats;
  final House? house;
  final List<QuickTask> quickTasks;
  
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
class HomeError extends HomeState {
  final String message;
}
```

---

### 3.4 TasksBloc (Cần Implement)

**Purpose:** Quản lý danh sách tasks

```dart
// Events
abstract class TasksEvent {}
class LoadTasks extends TasksEvent {
  final TaskFilter filter;
}
class RefreshTasks extends TasksEvent {}
class CreateCustomTask extends TasksEvent {
  final CustomTask task;
}
class DeleteTask extends TasksEvent {
  final String taskId;
}

// States
abstract class TasksState {}
class TasksInitial extends TasksState {}
class TasksLoading extends TasksState {}
class TasksLoaded extends TasksState {
  final List<Task> activeTasks;
  final List<Activity> completedActivities;
  final List<Task> savedRoutines;
  final TaskFilter currentFilter;
}
class TasksError extends TasksState {
  final String message;
}

// Filter enum
enum TaskFilter { active, completed, savedRoutines }
```

---

### 3.5 SessionBloc (Cần Implement)

**Purpose:** Quản lý active exercise session

```dart
// Events
abstract class SessionEvent {}
class StartSession extends SessionEvent {
  final Task task;
}
class PauseSession extends SessionEvent {}
class ResumeSession extends SessionEvent {}
class TimerTick extends SessionEvent {}
class CompleteSession extends SessionEvent {
  final int magicWipePercentage;
}
class CancelSession extends SessionEvent {}

// States
abstract class SessionState {}
class SessionInactive extends SessionState {}
class SessionActive extends SessionState {
  final Task task;
  final int elapsedSeconds;
  final int targetSeconds;
  final int estimatedCalories;
  final int estimatedPoints;
  final bool isPaused;
  
  String get formattedTime {
    final min = elapsedSeconds ~/ 60;
    final sec = elapsedSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
  
  double get progress => elapsedSeconds / targetSeconds;
}
class SessionCompleting extends SessionState {}
class SessionCompleted extends SessionState {
  final Activity activity;
  final int pointsEarned;
  final int newWalletBalance;
}
class SessionError extends SessionState {
  final String message;
}
```

**Key Logic:**
```dart
// Inside SessionBloc
Timer? _timer;

on<StartSession>((event, emit) {
  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) => add(TimerTick()),
  );
  emit(SessionActive(
    task: event.task,
    elapsedSeconds: 0,
    targetSeconds: event.task.durationMinutes * 60,
    isPaused: false,
  ));
});

on<TimerTick>((event, emit) {
  if (state is SessionActive) {
    final current = state as SessionActive;
    if (!current.isPaused) {
      emit(current.copyWith(
        elapsedSeconds: current.elapsedSeconds + 1,
        estimatedCalories: _calculateCalories(current.elapsedSeconds + 1),
        estimatedPoints: _calculatePoints(current.elapsedSeconds + 1),
      ));
    }
  }
});
```

---

### 3.6 LeaderboardBloc (Cần Implement)

**Purpose:** Quản lý bảng xếp hạng

```dart
// Events
abstract class LeaderboardEvent {}
class LoadLeaderboard extends LeaderboardEvent {
  final String? week; // e.g., "2025-W51"
}
class RefreshLeaderboard extends LeaderboardEvent {}

// States
abstract class LeaderboardState {}
class LeaderboardInitial extends LeaderboardState {}
class LeaderboardLoading extends LeaderboardState {}
class LeaderboardLoaded extends LeaderboardState {
  final String week;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<LeaderboardEntry> rankings;
  final String currentUserId;
  
  int get myRank {
    final index = rankings.indexWhere((r) => r.user.id == currentUserId);
    return index >= 0 ? index + 1 : -1;
  }
  
  List<LeaderboardEntry> get podium => rankings.take(3).toList();
  List<LeaderboardEntry> get runnersUp => rankings.skip(3).toList();
}
class LeaderboardError extends LeaderboardState {
  final String message;
}
```

---

### 3.7 ProfileBloc (Cần Implement)

**Purpose:** Quản lý profile screen data

```dart
// Events
abstract class ProfileEvent {}
class LoadProfile extends ProfileEvent {}
class RefreshProfile extends ProfileEvent {}

// States
abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final User user;
  final LifetimeStats stats;
  
  String get joinedYear => user.createdAt.year.toString();
  bool get isPro => user.subscription?.isActive ?? false;
}
class ProfileError extends ProfileState {
  final String message;
}
```

---

### 3.8 HouseBloc (Cần Implement)

**Purpose:** Quản lý House operations

```dart
// Events
abstract class HouseEvent {}
class LoadHouse extends HouseEvent {}
class CreateHouse extends HouseEvent {
  final String name;
}
class JoinHouse extends HouseEvent {
  final String inviteCode;
}
class LeaveHouse extends HouseEvent {}
class GetInviteLink extends HouseEvent {}

// States
abstract class HouseState {}
class HouseInitial extends HouseState {}
class HouseLoading extends HouseState {}
class NoHouse extends HouseState {}
class HouseLoaded extends HouseState {
  final House house;
  final List<HouseMember> members;
  final String? inviteCode;
  final String? inviteLink;
}
class HouseCreated extends HouseState {
  final House house;
}
class HouseJoined extends HouseState {
  final House house;
}
class HouseLeft extends HouseState {}
class HouseError extends HouseState {
  final String message;
}
```

---

## 4. Data Models

### 4.1 User Model

```dart
class User {
  final String id;
  final String firebaseUid;
  final String email;
  final String displayName;
  final int avatarId;
  final String? houseId;
  final int walletBalance;
  final AuthProvider provider;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  String get avatarUrl => 'assets/avatars/avatar_$avatarId.png';
}

enum AuthProvider { GOOGLE, APPLE }
```

### 4.2 Activity Model

```dart
class Activity {
  final String id;
  final String userId;
  final String taskName;
  final int durationSeconds;
  final double metsValue;
  final int magicWipePercentage;
  final int pointsEarned;
  final double? bonusMultiplier;
  final DateTime completedAt;
}
```

### 4.3 House Model

```dart
class House {
  final String id;
  final String name;
  final String inviteCode;
  final String ownerId;
  final DateTime createdAt;
}

class HouseMember {
  final User user;
  final int weeklyPoints;
  final int totalPoints;
  final String role; // 'owner' | 'member'
}
```

### 4.4 Task Model

```dart
class Task {
  final String? id;
  final String exerciseName;
  final String? taskDescription;
  final int durationMinutes;
  final int estimatedPoints;
  final double metsValue;
  final String iconName;
  final Color color;
  final bool isCustom;
}

class QuickTask extends Task {
  final int priority;
}
```

### 4.5 LeaderboardEntry Model

```dart
class LeaderboardEntry {
  final int rank;
  final User user;
  final int weeklyPoints;
  final int activityCount;
}
```

### 4.6 Stats Models

```dart
class WeeklyStats {
  final int totalPoints;
  final int activityCount;
  final int totalDurationMinutes;
  final int streakDays;
}

class LifetimeStats {
  final int totalPoints;
  final int totalActivities;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
}
```

---

## 5. Repository Layer

### 5.1 AuthRepository

```dart
abstract class AuthRepository {
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInWithApple();
  Future<User> getCurrentUser();
  Future<void> logout();
  Future<bool> isAuthenticated();
}
```

### 5.2 ActivityRepository

```dart
abstract class ActivityRepository {
  Future<Activity> createActivity({
    required String taskName,
    required int durationSeconds,
    required double metsValue,
    required int magicWipePercentage,
  });
  Future<PaginatedList<Activity>> getActivities({
    int page = 1,
    int limit = 20,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<LeaderboardResponse> getLeaderboard({String? week});
  Future<Stats> getStats({required String period});
}
```

### 5.3 HouseRepository

```dart
abstract class HouseRepository {
  Future<House> createHouse(String name);
  Future<House?> getCurrentHouse();
  Future<House> joinHouse(String inviteCode);
  Future<void> leaveHouse();
  Future<InviteDetails> getInviteDetails();
  Future<HousePreview> previewHouse(String code);
}
```

### 5.4 UserRepository

```dart
abstract class UserRepository {
  Future<User> updateProfile({
    String? displayName,
    int? avatarId,
  });
  Future<void> updateFcmToken(String token);
  Future<User> getUser(String userId);
}
```

---

## 6. Service Locator Setup

```dart
// lib/core/di/service_locator.dart
GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  sl.registerLazySingleton<ApiService>(() => ApiService());
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<StorageService>(() => StorageService());
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<HouseRepository>(
    () => HouseRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl()),
  );
  
  // BLoCs
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<UserBloc>(() => UserBloc(sl()));
  sl.registerFactory<HomeBloc>(() => HomeBloc(sl(), sl(), sl()));
  sl.registerFactory<TasksBloc>(() => TasksBloc(sl()));
  sl.registerFactory<SessionBloc>(() => SessionBloc(sl()));
  sl.registerFactory<LeaderboardBloc>(() => LeaderboardBloc(sl()));
  sl.registerFactory<ProfileBloc>(() => ProfileBloc(sl(), sl()));
  sl.registerFactory<HouseBloc>(() => HouseBloc(sl()));
}
```

---

## 7. Implementation Priority

### Phase 1: Core (Essential)
1. ✅ `AuthBloc` - Đã có
2. 🔲 `UserBloc` - User profile management
3. 🔲 `SessionBloc` - Active session (critical for core feature)

### Phase 2: Features
4. 🔲 `HomeBloc` - Home screen data
5. 🔲 `TasksBloc` - Task list management
6. 🔲 `LeaderboardBloc` - Rankings

### Phase 3: Enhancement
7. 🔲 `ProfileBloc` - Profile screen
8. 🔲 `HouseBloc` - House management
9. 🔲 `RewardBloc` - Rewards & redemptions (future)

---

## 8. Testing Strategy

### 8.1 Unit Tests

```dart
// test/blocs/session_bloc_test.dart
void main() {
  group('SessionBloc', () {
    late SessionBloc bloc;
    late MockActivityRepository mockRepo;
    
    setUp(() {
      mockRepo = MockActivityRepository();
      bloc = SessionBloc(mockRepo);
    });
    
    test('starts session correctly', () {
      final task = Task(name: 'Test', durationMinutes: 20);
      
      bloc.add(StartSession(task));
      
      expect(
        bloc.stream,
        emitsInOrder([
          isA<SessionActive>()
            .having((s) => s.elapsedSeconds, 'elapsed', 0)
            .having((s) => s.isPaused, 'paused', false),
        ]),
      );
    });
  });
}
```

### 8.2 Integration Tests

```dart
// integration_test/session_flow_test.dart
void main() {
  testWidgets('complete session flow', (tester) async {
    await tester.pumpWidget(MyApp());
    
    // Start session
    await tester.tap(find.byType(TaskCard).first);
    await tester.pumpAndSettle();
    
    // Verify timer running
    expect(find.text('00:00'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('00:05'), findsOneWidget);
    
    // Complete session
    await tester.drag(find.byType(SwipeButton), const Offset(200, 0));
    await tester.pumpAndSettle();
    
    // Verify completion
    expect(find.text('Session Completed'), findsOneWidget);
  });
}
```
