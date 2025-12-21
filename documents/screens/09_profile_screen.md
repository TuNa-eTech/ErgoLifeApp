# ProfileScreen - Màn Hình Hồ Sơ

## 1. Thông Tin Chung

| Property | Value |
|----------|-------|
| **File** | `lib/ui/screens/profile/profile_screen.dart` |
| **Route** | `/profile` |
| **Type** | `StatelessWidget` |
| **Tab Index** | 3 (Profile) |

---

## 2. Mục Đích

- Hiển thị thông tin cá nhân của user
- Thống kê lifetime (total EP, workouts)
- Truy cập settings và preferences
- Logout functionality

---

## 3. UI Components

### 3.1 Widget Hierarchy

```
Scaffold
└── SingleChildScrollView (padding bottom 100)
    └── Column
        ├── Header Row
        │   ├── Title "Profile"
        │   └── Settings Button
        └── Padding (horizontal 24)
            └── Column
                ├── Profile Card
                │   ├── Avatar (with edit button)
                │   ├── Name "Minh Nguyen"
                │   ├── Badges (PRO MEMBER, Joined 2023)
                │   └── Action Buttons Row
                │       ├── Share Profile
                │       └── View Reports
                ├── Stats Section "Lifetime Stats"
                │   ├── StatCard: Total EP (14.2k)
                │   └── StatCard: Workouts (128)
                ├── Preferences Section
                │   ├── Edit Profile Details
                │   ├── Notifications
                │   └── App Settings
                └── Logout Button
```

---

## 4. Header Section

### 4.1 Structure
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Profile', style: bold 28px),
    SettingsButton (circle, 40×40, settings_outlined icon),
  ],
)
```

---

## 5. Profile Card

### 5.1 Structure
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: 24,
    boxShadow: [...],
  ),
  child: Stack(
    children: [
      // Background glows (decorative circles)
      Positioned(top-right, circle, primary color 5%),
      Positioned(bottom-left, circle, secondary color 5%),
      
      // Content
      Padding(
        child: Column(
          children: [
            AvatarWithEditButton,
            Name,
            BadgesRow,
            ActionButtonsRow,
          ],
        ),
      ),
    ],
  ),
)
```

### 5.2 Avatar Component
```dart
Stack(
  children: [
    // Outer container with border
    Container(
      padding: 6,
      border: Border.all(grey),
      child: CircleAvatar(
        width: 100, height: 100,
        image: NetworkImage(...),
      ),
    ),
    // Edit button (positioned bottom-right)
    Positioned(
      bottom: 4, right: 4,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          shape: circle,
          border: Border.all(white, 2),
        ),
        child: Icon(edit, size: 14),
      ),
    ),
  ],
)
```

### 5.3 Badges Row
```dart
Row(
  children: [
    Container(
      text: 'PRO MEMBER',
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: 20,
      ),
    ),
    Text('Joined 2023'),
  ],
)
```

### 5.4 Action Buttons

| Button | Icon | Style | Action |
|--------|------|-------|--------|
| Share Profile | share | Grey background | TODO |
| View Reports | insights | Orange, with shadow | TODO |

---

## 6. Stats Section

### 6.1 Section Title
```dart
Text('Lifetime Stats', style: bold 18px)
```

### 6.2 Stat Cards
```dart
Row(
  children: [
    Expanded(StatCard: Total EP, value: '14.2k'),
    SizedBox(width: 16),
    Expanded(StatCard: Workouts, value: '128'),
  ],
)
```

### 6.3 StatCard Component
```dart
Container(
  padding: 20,
  decoration: BoxDecoration(
    color: surface,
    borderRadius: 16,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      IconBox (40×40, rounded 12),
      SizedBox(height: 12),
      Text(value, style: bold 28px),
      Text(label, style: 12px, letterSpacing 0.5),
    ],
  ),
)
```

### 6.4 Hardcoded Stats

| Stat | Icon | Value | Label | Color |
|------|------|-------|-------|-------|
| Total EP | bolt | 14.2k | Total EP | Orange |
| Workouts | fitness_center | 128 | Workouts | Blue |

---

## 7. Preferences Section

### 7.1 Structure
```dart
Column(
  children: [
    Text('Preferences'),
    Container(
      decoration: BoxDecoration(
        borderRadius: 16,
      ),
      child: Column(
        children: [
          PreferenceItem(person_outline, 'Edit Profile Details'),
          Divider(),
          PreferenceItem(notifications_none, 'Notifications'),
          Divider(),
          PreferenceItem(tune, 'App Settings'),
        ],
      ),
    ),
    LogoutButton,
  ],
)
```

### 7.2 PreferenceItem Component
```dart
InkWell(
  onTap: () {},
  child: Padding(
    padding: 20,
    child: Row(
      children: [
        IconCircle (40×40),
        SizedBox(width: 16),
        Text(label, style: bold 14px),
        Spacer(),
        Icon(chevron_right),
      ],
    ),
  ),
)
```

### 7.3 Preference Items

| Icon | Label | Action |
|------|-------|--------|
| person_outline | Edit Profile Details | TODO: Edit profile screen |
| notifications_none | Notifications | TODO: Notification settings |
| tune | App Settings | TODO: App settings screen |

### 7.4 Logout Button
```dart
TextButton(
  onPressed: _logout,
  child: Text(
    'Log Out',
    style: TextStyle(color: Colors.red, fontWeight: bold),
  ),
)
```

---

## 8. User Interactions

| Element | Action | Effect |
|---------|--------|--------|
| Settings button | Tap | TODO: Navigate to settings |
| Avatar edit button | Tap | TODO: Change avatar |
| Share Profile | Tap | TODO: Share profile link |
| View Reports | Tap | TODO: Navigate to reports |
| Edit Profile Details | Tap | TODO: Edit profile screen |
| Notifications | Tap | TODO: Notification settings |
| App Settings | Tap | TODO: App settings |
| Log Out | Tap | TODO: Logout and navigate to login |

---

## 9. API Integration

### 9.1 APIs Cần Gọi

| API | Method | Purpose |
|-----|--------|---------|
| `GET /auth/me` | GET | Fetch user info |
| `GET /activities/stats?period=all` | GET | Fetch lifetime stats |
| `PUT /users/me` | PUT | Update profile |
| `POST /auth/logout` | POST | Logout (optional) |

### 9.2 User Info Mapping

| UI Element | API Field |
|------------|-----------|
| Avatar | `avatarId` → asset/URL mapping |
| Name | `displayName` |
| PRO MEMBER badge | Subscription status (future) |
| Joined year | `createdAt` |

### 9.3 Stats Mapping

| UI Element | API Field |
|------------|-----------|
| Total EP | `/activities/stats` → `totalPoints` |
| Workouts | `/activities/stats` → `totalActivities` |

---

## 10. State Management

### 10.1 Cần Implement

```dart
// ProfileBloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  on<LoadProfile>((event, emit) async {
    emit(ProfileLoading());
    try {
      final user = await userRepo.getCurrentUser();
      final stats = await activityRepo.getStats(period: 'all');
      emit(ProfileLoaded(user, stats));
    } catch (e) {
      emit(ProfileError(e.message));
    }
  });
  
  on<Logout>((event, emit) async {
    await authRepo.logout();
    emit(ProfileLoggedOut());
  });
}
```

### 10.2 ProfileState

```dart
class ProfileLoaded extends ProfileState {
  final User user;
  final LifetimeStats stats;
  
  String get joinedYear => user.createdAt.year.toString();
  bool get isPro => user.subscription?.isActive ?? false;
}
```

---

## 11. Cải Tiến Đề Xuất

### 11.1 Issues Hiện Tại
- ⚠️ All data hardcoded
- ⚠️ All buttons are TODO
- ⚠️ No loading state
- ⚠️ Logout chưa implement

### 11.2 Logout Implementation

```dart
void _logout() async {
  final confirmed = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Log Out'),
      content: Text('Are you sure you want to log out?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Log Out')),
      ],
    ),
  );
  
  if (confirmed == true) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
    context.go(AppRouter.login);
  }
}
```

### 11.3 Additional Stats (Future)

Thêm stats:
- Current Streak
- Longest Streak
- Calories Burned (estimated)
- Hours Active

```dart
GridView.count(
  crossAxisCount: 2,
  children: [
    StatCard('Total EP', '14.2k'),
    StatCard('Workouts', '128'),
    StatCard('Streak', '5 days'),
    StatCard('Calories', '12.5k'),
  ],
)
```

### 11.4 House Section

Thêm section hiển thị House info:

```dart
_buildHouseSection() {
  return Container(
    child: Column(
      children: [
        Text('My House'),
        Row(
          children: [
            HouseInfo(name: 'Nhà của Mèo', members: 3),
            TextButton('Leave House', onPressed: _leaveHouse),
          ],
        ),
      ],
    ),
  );
}
```

### 11.5 Dark Mode Toggle

```dart
_buildPreferenceItem(
  icon: Icons.dark_mode,
  label: 'Dark Mode',
  trailing: Switch(
    value: isDark,
    onChanged: (value) {
      // Toggle theme
    },
  ),
)
```

---

## 12. Responsive Considerations

- ScrollView handles different screen sizes
- Stat cards flex equally in row
- Profile avatar centered
- Preference items full width
