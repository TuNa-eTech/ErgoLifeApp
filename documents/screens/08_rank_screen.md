# RankScreen - Màn Hình Bảng Xếp Hạng

## 1. Thông Tin Chung

| Property | Value |
|----------|-------|
| **File** | `lib/ui/screens/rank/rank_screen.dart` |
| **Route** | `/rank` |
| **Type** | `StatelessWidget` |
| **Tab Index** | 1 (Rank) |

---

## 2. Mục Đích

- Hiển thị bảng xếp hạng trong House
- Podium cho top 3
- Danh sách runners-up
- Invite button để mời thành viên mới

---

## 3. UI Components

### 3.1 Widget Hierarchy

```
Scaffold
└── Stack
    ├── SingleChildScrollView (padding bottom 100)
    │   └── Column
    │       ├── Header Section
    │       │   ├── Title + Search button
    │       │   └── Filter Toggle (Friends/Global)
    │       ├── Podium Section
    │       │   ├── Rank 2 (left)
    │       │   ├── Rank 1 (center, elevated)
    │       │   └── Rank 3 (right)
    │       └── Runners Up Section
    │           ├── Title "Runners up"
    │           └── List Items (4, 5, 6, 7...)
    └── Positioned (bottom right)
        └── Invite Button
```

---

## 4. Header Section

### 4.1 Title Row
```dart
Row(
  children: [
    Column(
      children: [
        Text('COMPETITION', style: smallCaps),
        Text('Leaderboard 🏆', style: bold 28px),
      ],
    ),
    SearchButton (circle, 48×48),
  ],
)
```

### 4.2 Filter Toggle
```dart
Container(
  child: Row(
    children: [
      TabButton('Friends', isActive: true, color: orange),
      TabButton('Global', isActive: false),
    ],
  ),
)
```

| Tab | Status | Purpose |
|-----|--------|---------|
| Friends | ✅ Active | Leaderboard trong House |
| Global | ❌ Inactive | Leaderboard toàn app (future) |

---

## 5. Podium Section

### 5.1 Layout
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Expanded(PodiumItem rank 2),  // height: 140
    Expanded(PodiumItem rank 1),  // height: 170, offset: -16
    Expanded(PodiumItem rank 3),  // height: 140
  ],
)
```

### 5.2 PodiumItem Component

```dart
Column(
  children: [
    if (showCrown) Icon(emoji_events),
    Stack(
      children: [
        Container(  // Card
          height: height,
          child: Column(
            children: [
              Spacer(),
              Text(name),
              Text(score, color: orange),
              if (showCrown) Badge('LEADER'),
            ],
          ),
        ),
        Positioned(  // Avatar
          top: -24,
          child: CircleAvatar(emoji),
        ),
        Positioned(  // Rank badge
          top: 8, right: 8,
          child: CircleBadge(rank),
        ),
      ],
    ),
  ],
)
```

### 5.3 Podium Props

| Prop | Type | Description |
|------|------|-------------|
| `rank` | `int` | 1, 2, or 3 |
| `name` | `String` | User name |
| `score` | `String` | Points (formatted) |
| `avatar` | `String` | Emoji avatar |
| `color` | `Color` | Theme color |
| `height` | `double` | Card height |
| `showCrown` | `bool` | Show crown for rank 1 |

### 5.4 Hardcoded Podium Data

| Rank | Name | Score | Avatar | Color |
|------|------|-------|--------|-------|
| 1 | Sarah M. | 2,480 | 🦊 | Orange |
| 2 | Alex K. | 2,150 | 😎 | Grey |
| 3 | Mike R. | 1,920 | 🏋️ | Light Orange |

---

## 6. Runners Up Section

### 6.1 List Structure
```dart
Column(
  children: [
    Text('Runners up'),
    ListItem(rank: 4, ...),
    ListItem(rank: 5, ...),
    ListItem(rank: 6, ...),
    ListItem(rank: 7, ...),
  ],
)
```

### 6.2 ListItem Component

```dart
Container(
  border: isMe ? BorderSide(left: orange, width: 4) : null,
  child: Row(
    children: [
      Text(rank),
      Avatar(isMe ? image : initials),
      Column(
        children: [
          Text(name),
          Row(
            children: [
              if (isMe) Icon(arrow_up, green),
              Text(status),
            ],
          ),
        ],
      ),
      Column(
        children: [
          Text(score, weight: 900),
          Text('EP'),
        ],
      ),
    ],
  ),
)
```

### 6.3 ListItem Props

| Prop | Type | Description |
|------|------|-------------|
| `rank` | `int` | Rank number |
| `name` | `String` | User name |
| `score` | `String` | Points |
| `status` | `String` | Status text (e.g., "Rising fast") |
| `isMe` | `bool` | Highlight current user |
| `initials` | `String?` | Initials for avatar |
| `avatarColor` | `Color?` | Avatar background color |
| `textColor` | `Color?` | Initials text color |

### 6.4 Hardcoded Runners Up Data

| Rank | Name | Score | Status | Me? |
|------|------|-------|--------|-----|
| 4 | Minh (You) | 1,240 | Rising fast | ✅ |
| 5 | David Kim | 1,100 | Consistent | ❌ |
| 6 | Jenny Lee | 1,050 | On fire 🔥 | ❌ |
| 7 | Marcus P. | 980 | - | ❌ |

---

## 7. Invite Button

### 7.1 Structure
```dart
Positioned(
  bottom: 24, right: 24,
  child: Material(
    color: AppColors.textMainLight, // Dark navy
    borderRadius: 30,
    child: InkWell(
      child: Row(
        children: [
          Icon(person_add),
          Text('Invite'),
        ],
      ),
    ),
  ),
)
```

### 7.2 Action
- TODO: Show invite options (share link, QR code)

---

## 8. User Interactions

| Element | Action | Effect |
|---------|--------|--------|
| Search button | Tap | TODO: Search users |
| Friends/Global toggle | Tap | TODO: Filter leaderboard |
| User list item | Tap | TODO: View user profile? |
| Invite button | Tap | TODO: Share invite link |

---

## 9. API Integration

### 9.1 API Endpoints

| API | Method | Purpose |
|-----|--------|---------|
| `GET /activities/leaderboard` | GET | Fetch weekly rankings |
| `GET /houses/mine` | GET | Get house members info |
| `GET /houses/invite` | GET | Get invite link/code |

### 9.2 Leaderboard API

**Request:**
```http
GET /activities/leaderboard?week=2025-W51
```

**Response:**
```json
{
  "success": true,
  "data": {
    "week": "2025-W51",
    "weekStart": "2025-12-16T00:00:00Z",
    "weekEnd": "2025-12-22T23:59:59Z",
    "rankings": [
      {
        "rank": 1,
        "user": {
          "id": "...",
          "displayName": "Sarah M.",
          "avatarId": 3
        },
        "weeklyPoints": 2480,
        "activityCount": 15
      },
      {
        "rank": 2,
        "user": {
          "id": "...",
          "displayName": "Alex K.",
          "avatarId": 2
        },
        "weeklyPoints": 2150,
        "activityCount": 12
      }
      // ...
    ]
  }
}
```

### 9.3 Data Mapping

| UI Element | API Field |
|------------|-----------|
| Name | `rankings[i].user.displayName` |
| Score | `rankings[i].weeklyPoints` |
| Avatar | Map from `avatarId` or use initials |
| Is Me | Compare `rankings[i].user.id` with current user |

---

## 10. State Management

### 10.1 Cần Implement

```dart
// LeaderboardBloc  
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  on<LoadLeaderboard>((event, emit) async {
    emit(LeaderboardLoading());
    try {
      final rankings = await activityRepo.getLeaderboard(
        week: event.week,
      );
      emit(LeaderboardLoaded(rankings));
    } catch (e) {
      emit(LeaderboardError(e.message));
    }
  });
}
```

### 10.2 LeaderboardState

```dart
class LeaderboardLoaded extends LeaderboardState {
  final String week;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<LeaderboardEntry> rankings;
  final String currentUserId;
  
  int get myRank => rankings.indexWhere(
    (r) => r.user.id == currentUserId
  ) + 1;
}
```

---

## 11. Cải Tiến Đề Xuất

### 11.1 Issues Hiện Tại
- ⚠️ All data hardcoded
- ⚠️ Filter toggle không hoạt động
- ⚠️ Search không hoạt động
- ⚠️ Invite button chưa implement
- ⚠️ Avatar dùng emoji thay vì actual images

### 11.2 Week Selector

Thêm chọn tuần để xem lịch sử:

```dart
Row(
  children: [
    IconButton(icon: arrow_back, onPressed: _prevWeek),
    Text('Week ${_currentWeek}'),
    IconButton(icon: arrow_forward, onPressed: _nextWeek),
  ],
)
```

### 11.3 Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () => context.read<LeaderboardBloc>().add(LoadLeaderboard()),
  child: SingleChildScrollView(...),
)
```

### 11.4 Loading States

```dart
BlocBuilder<LeaderboardBloc, LeaderboardState>(
  builder: (context, state) {
    if (state is LeaderboardLoading) {
      return ShimmerLoading(); // Skeleton UI
    }
    if (state is LeaderboardError) {
      return ErrorWidget(state.message);
    }
    return LeaderboardContent(state.rankings);
  },
)
```

### 11.5 Invite Flow

```dart
void _showInviteSheet() {
  showModalBottomSheet(
    context: context,
    builder: (context) => InviteSheet(
      inviteCode: house.inviteCode,
      deepLink: house.inviteLink,
      qrCodeUrl: house.qrCodeUrl,
    ),
  );
}
```

---

## 12. Avatar System

### 12.1 Current (Emoji)
```dart
String avatar = '🦊'; // Hardcoded emoji
```

### 12.2 Proposed (Avatar ID System)
```dart
// Map avatarId to actual image URL or asset
String getAvatarUrl(int avatarId) {
  return 'https://storage.ergolife.app/avatars/$avatarId.png';
}

// Or use predefined emoji mapping
const avatarEmojis = {
  1: '🦊',
  2: '😎',
  3: '🏋️',
  4: '🎯',
  // ...
};
```

---

## 13. Responsive Considerations

- Podium items flex equally
- List items full width
- Invite button positioned absolute
- Handles different score lengths (formatting)
