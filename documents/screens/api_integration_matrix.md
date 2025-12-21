# API Integration Matrix - Tích Hợp API Cho Từng Màn Hình

## 1. Tổng Quan

Tài liệu này mô tả chi tiết việc tích hợp API cho từng màn hình của ứng dụng ErgoLife, bao gồm:
- APIs cần gọi
- Timing (khi nào gọi)
- Data mapping
- Error handling

---

## 2. API Endpoints Summary

| Module | Endpoint | Method | Auth |
|--------|----------|--------|------|
| **Auth** | `/auth/social-login` | POST | ❌ |
|  | `/auth/me` | GET | ✅ |
|  | `/auth/logout` | POST | ✅ |
| **Users** | `/users/me` | PUT | ✅ |
|  | `/users/me/fcm-token` | PUT | ✅ |
| **Houses** | `/houses` | POST | ✅ |
|  | `/houses/mine` | GET | ✅ |
|  | `/houses/join` | POST | ✅ |
|  | `/houses/leave` | POST | ✅ |
|  | `/houses/invite` | GET | ✅ |
| **Activities** | `/activities` | POST | ✅ |
|  | `/activities` | GET | ✅ |
|  | `/activities/leaderboard` | GET | ✅ |
|  | `/activities/stats` | GET | ✅ |
| **Rewards** | `/rewards` | GET | ✅ |
|  | `/rewards` | POST | ✅ |
|  | `/rewards/:id/redeem` | POST | ✅ |
| **Redemptions** | `/redemptions` | GET | ✅ |

---

## 3. Screen-API Mapping

### 3.1 Matrix Overview

| Screen | Auth | Users | Houses | Activities | Rewards |
|--------|------|-------|--------|------------|---------|
| Splash | `GET /auth/me` | - | - | - | - |
| Login | `POST /auth/social-login` | - | - | - | - |
| Onboarding | - | `PUT /users/me` | `POST /houses` | - | - |
| Home | `GET /auth/me` | - | `GET /houses/mine` | `GET /activities/stats` | - |
| Tasks | - | - | - | `GET /activities` | - |
| Create Task | - | - | - | - | - |
| Active Session | - | - | - | `POST /activities` | - |
| Rank | - | - | `GET /houses/mine` | `GET /activities/leaderboard` | - |
| Profile | `GET /auth/me` | `PUT /users/me` | `POST /houses/leave` | `GET /activities/stats` | `GET /redemptions` |

---

## 4. Detailed Screen Integration

### 4.1 SplashScreen

```mermaid
sequenceDiagram
    participant S as SplashScreen
    participant B as AuthBloc
    participant API as Backend
    
    S->>B: AuthCheckRequested
    B->>API: GET /auth/me
    
    alt Token Valid
        API-->>B: 200 { user }
        B-->>S: AuthAuthenticated
        S->>S: Navigate to Home
    else Token Invalid/Expired
        API-->>B: 401 Unauthorized
        B-->>S: AuthUnauthenticated
        S->>S: Navigate to Login
    end
```

**APIs:**
| API | Trigger | Success | Failure |
|-----|---------|---------|---------|
| `GET /auth/me` | On init | → Home | → Login |

---

### 4.2 LoginScreen

```mermaid
sequenceDiagram
    participant L as LoginScreen
    participant B as AuthBloc
    participant FB as Firebase
    participant API as Backend
    
    L->>B: AuthGoogleSignInRequested
    B->>FB: signInWithGoogle()
    FB-->>B: Firebase ID Token
    B->>API: POST /auth/social-login { idToken }
    
    alt New User
        API-->>B: 200 { accessToken, user, isNewUser: true }
        B-->>L: AuthAuthenticated(isNew: true)
        L->>L: Navigate to Onboarding
    else Existing User
        API-->>B: 200 { accessToken, user, isNewUser: false }
        B-->>L: AuthAuthenticated(isNew: false)
        L->>L: Navigate to Home (or Onboarding if no house)
    end
```

**APIs:**
| API | Trigger | Payload | Success | Failure |
|-----|---------|---------|---------|---------|
| `POST /auth/social-login` | Google/Apple button | `{ idToken }` | → Onboarding/Home | Show error |

---

### 4.3 OnboardingScreen

```mermaid
sequenceDiagram
    participant O as OnboardingScreen
    participant B as Bloc(s)
    participant API as Backend
    
    Note over O: Step 1: Avatar & Name
    Note over O: Step 2: Sync Bio
    Note over O: Step 3: Choose Mode
    
    O->>B: FinishOnboarding
    
    par Update Profile
        B->>API: PUT /users/me { displayName, avatarId }
        API-->>B: Updated user
    and Create House
        B->>API: POST /houses { name }
        API-->>B: House created
    end
    
    B-->>O: OnboardingComplete
    O->>O: Navigate to Home
```

**APIs:**
| API | Trigger | Payload |
|-----|---------|---------|
| `PUT /users/me` | Finish onboarding | `{ displayName, avatarId }` |
| `POST /houses` | Finish onboarding | `{ name }` |

---

### 4.4 HomeScreen

```mermaid
sequenceDiagram
    participant H as HomeScreen
    participant B as Bloc(s)
    participant API as Backend
    
    H->>B: LoadHomeData
    
    par Get User
        B->>API: GET /auth/me
        API-->>B: User data
    and Get Stats
        B->>API: GET /activities/stats?period=week
        API-->>B: Weekly stats
    and Get House
        B->>API: GET /houses/mine
        API-->>B: House info
    end
    
    B-->>H: HomeDataLoaded
    H->>H: Render dashboard
```

**APIs:**
| API | Purpose | Data Used |
|-----|---------|-----------|
| `GET /auth/me` | User info | `displayName` for greeting |
| `GET /activities/stats?period=week` | Weekly stats | `totalPoints`, `activityCount` |
| `GET /houses/mine` | House info | For arena comparison |

---

### 4.5 TasksScreen

```mermaid
sequenceDiagram
    participant T as TasksScreen
    participant B as Bloc
    participant API as Backend
    
    T->>B: LoadTasks
    B->>API: GET /activities?page=1&limit=20
    API-->>B: Activity history
    B-->>T: TasksLoaded
```

**APIs:**
| API | Purpose | Query Params |
|-----|---------|--------------|
| `GET /activities` | Completed activities | `page`, `limit`, `status` |

**Note:** Active/pending tasks hiện chưa có API, sử dụng predefined list hoặc local storage.

---

### 4.6 CreateTaskScreen

**Currently:** Không gọi API - chỉ local.

**Future:**
| API | Purpose | Payload |
|-----|---------|---------|
| `POST /tasks/custom` | Save custom task | `{ exerciseName, description, duration, metsValue, icon }` |

---

### 4.7 ActiveSessionScreen

```mermaid
sequenceDiagram
    participant A as ActiveSession
    participant B as SessionBloc
    participant API as Backend
    
    Note over A: User performs task...
    Note over A: Timer running...
    
    A->>A: Swipe to complete
    A->>B: CompleteSession(data)
    
    B->>API: POST /activities
    API-->>B: Activity created
    
    B-->>A: SessionCompleted
    A->>A: Show success, pop
```

**APIs:**
| API | Trigger | Payload |
|-----|---------|---------|
| `POST /activities` | Swipe complete | `{ taskName, durationSeconds, metsValue, magicWipePercentage }` |

**Response Data Used:**
- `pointsEarned` - Show in success animation
- `wallet.newBalance` - Update UI if visible
- `bonusMultiplier` - Show bonus indicator

---

### 4.8 RankScreen

```mermaid
sequenceDiagram
    participant R as RankScreen
    participant B as LeaderboardBloc
    participant API as Backend
    
    R->>B: LoadLeaderboard
    
    par Get Leaderboard
        B->>API: GET /activities/leaderboard?week=current
        API-->>B: Rankings
    and Get House
        B->>API: GET /houses/mine
        API-->>B: House members
    end
    
    B-->>R: LeaderboardLoaded
    R->>R: Render podium & list
```

**APIs:**
| API | Purpose | Query Params |
|-----|---------|--------------|
| `GET /activities/leaderboard` | Weekly rankings | `week` (e.g., `2025-W51`) |
| `GET /houses/mine` | House members | - |
| `GET /houses/invite` | Invite code (for button) | - |

---

### 4.9 ProfileScreen

```mermaid
sequenceDiagram
    participant P as ProfileScreen
    participant B as Bloc(s)
    participant API as Backend
    
    P->>B: LoadProfile
    
    par Get User
        B->>API: GET /auth/me
        API-->>B: User data
    and Get Stats
        B->>API: GET /activities/stats?period=all
        API-->>B: Lifetime stats
    end
    
    B-->>P: ProfileLoaded
    
    opt Logout
        P->>B: Logout
        B->>API: POST /auth/logout
        B->>B: Clear local tokens
        B-->>P: Navigate to Login
    end
```

**APIs:**
| API | Purpose |
|-----|---------|
| `GET /auth/me` | User info |
| `GET /activities/stats?period=all` | Lifetime stats |
| `PUT /users/me` | Edit profile |
| `POST /auth/logout` | Logout |
| `POST /houses/leave` | Leave house |
| `GET /redemptions` | Redemption history |

---

## 5. Error Handling Strategy

### 5.1 Common Error Codes

| Code | Message | Action |
|------|---------|--------|
| 401 | Unauthorized | Redirect to login |
| 403 | Forbidden | Show permission error |
| 404 | Not Found | Show not found message |
| 422 | Validation Error | Show field errors |
| 500 | Server Error | Show retry option |
| Network | No connection | Show offline mode |

### 5.2 Global Error Handler

```dart
class ApiErrorHandler {
  static void handle(BuildContext context, ApiError error) {
    switch (error.code) {
      case 401:
        // Clear auth, navigate to login
        context.read<AuthBloc>().add(AuthSessionExpired());
        context.go(AppRouter.login);
        break;
      case 403:
        showSnackBar(context, 'You do not have permission');
        break;
      default:
        showSnackBar(context, error.message);
    }
  }
}
```

---

## 6. Caching Strategy

### 6.1 Cache Rules

| Data | Cache Duration | Invalidation |
|------|----------------|--------------|
| User profile | 5 minutes | On update |
| Weekly stats | 5 minutes | On activity creation |
| Leaderboard | 1 minute | On pull refresh |
| House info | 10 minutes | On join/leave |
| Activities list | 5 minutes | On activity creation |

### 6.2 Implementation

```dart
class CachedRepository {
  final _cache = <String, CacheEntry>{};
  
  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration ttl = const Duration(minutes: 5),
  }) async {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }
    
    final data = await fetcher();
    _cache[key] = CacheEntry(data, ttl);
    return data;
  }
}
```

---

## 7. Loading States

### 7.1 Per Screen

| Screen | Loading UI |
|--------|------------|
| Splash | Progress bar |
| Login | Circular indicator |
| Home | Skeleton/shimmer |
| Tasks | Skeleton list |
| Rank | Skeleton podium |
| Profile | Skeleton cards |

### 7.2 Implementation

```dart
BlocBuilder<HomeBloc, HomeState>(
  builder: (context, state) {
    if (state is HomeLoading) {
      return HomeSkeletonScreen();
    }
    if (state is HomeError) {
      return ErrorScreen(
        message: state.message,
        onRetry: () => context.read<HomeBloc>().add(LoadHome()),
      );
    }
    return HomeContent(state.data);
  },
)
```

---

## 8. Realtime Updates (Future)

### 8.1 WebSocket Events

| Event | Screens Affected | Action |
|-------|------------------|--------|
| `activity.created` | Rank, Home | Refresh leaderboard |
| `reward.redeemed` | (Notification) | Show notification |
| `house.member.joined` | Rank | Refresh house members |
| `house.member.left` | Rank | Refresh house members |

### 8.2 Implementation (Future)

```dart
class RealtimeService {
  late WebSocketChannel _channel;
  
  void connect(String token) {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://api.ergolife.app/ws?token=$token'),
    );
    
    _channel.stream.listen((event) {
      final data = jsonDecode(event);
      _eventController.add(RealtimeEvent.fromJson(data));
    });
  }
}
```
