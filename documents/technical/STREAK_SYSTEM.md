# Streak Tracking System

## Overview

ErgoLifeApp implements a **Duolingo-style streak tracking system** that rewards users for daily consistency in completing activities. The system includes:

- **Daily Streak Counter**: Tracks consecutive days of activity completion
- **Streak Freeze Mechanic**: Purchasable protection against losing streak
- **Milestone Celebrations**: Special rewards at key milestones (7, 14, 30, 60, 100, 365 days)
- **Automatic Recovery**: Auto-uses Streak Freeze when user misses a day
- **Bonus Rewards**: Free Streak Freeze awarded at 100-day milestone

---

## Database Schema

### User Model Fields

```prisma
model User {
  // ... existing fields
  
  // Streak tracking
  currentStreak      Int      @default(0)
  longestStreak      Int      @default(0)
  lastActivityDate   DateTime?
  streakFreezeCount  Int      @default(0)  // Max: 2
}
```

**Migration:** `20260108140418_add_streak_tracking`

---

## Backend Implementation

### 1. Streak Update Logic

**Location:** `backend/src/modules/activities/activities.service.ts`

**Method:** `updateStreakAfterActivity(userId: string)`

**Trigger:** Called automatically after successful activity creation

**Logic Flow:**

```typescript
// Pseudo-code
const daysDiff = calculateDaysDifference(today, lastActivityDate);

if (daysDiff === 0) {
  return 'STREAK_MAINTAINED'; // Same day, no change
}

if (daysDiff === 1) {
  currentStreak++;
  return 'STREAK_INCREASED'; // Next day, increment
}

if (daysDiff === 2 && streakFreezeCount > 0) {
  streakFreezeCount--;
  return 'STREAK_FREEZE_USED'; // Missed 1 day, auto-use freeze
}

// Missed 2+ days or no freeze
currentStreak = 1;
return 'STREAK_RESET';

// Special: 100-day bonus
if (currentStreak === 100 && streakFreezeCount < 2) {
  streakFreezeCount++;
  return 'STREAK_FREEZE_BONUS';
}
```

**Return Object:**

```typescript
interface StreakUpdate {
  previousStreak: number;
  currentStreak: number;
  longestStreak: number;
  streakFreezeCount: number;
  message: 'STREAK_INCREASED' | 'STREAK_STARTED' | 'STREAK_MAINTAINED' 
         | 'STREAK_FREEZE_USED' | 'STREAK_FREEZE_BONUS' | 'STREAK_RESET';
  info?: string; // Optional user-facing message
}
```

### 2. API Endpoints

#### POST /activities

**Response includes streak data:**

```json
{
  "success": true,
  "data": {
    "activity": { /* ... */ },
    "wallet": { /* ... */ },
    "streak": {
      "previousStreak": 14,
      "currentStreak": 15,
      "longestStreak": 28,
      "streakFreezeCount": 1,
      "message": "STREAK_INCREASED",
      "info": null
    }
  }
}
```

#### PUT /users/purchase-streak-freeze

**Purchase Streak Freeze protection**

**Cost:** 500 EP  
**Max:** 2 Freezes

**Request:** No body required

**Response:**

```json
{
  "success": true,
  "data": {
    "message": "Streak Freeze purchased successfully",
    "newBalance": 1500,
    "streakFreezeCount": 1
  }
}
```

**Error Responses:**

- `400`: Insufficient balance
- `400`: Maximum Freezes reached (2)
- `403`: Not in a house

#### GET /auth/me

**Returns user profile including streak data:**

```json
{
  "success": true,
  "data": {
    "id": "...",
    "currentStreak": 15,
    "longestStreak": 28,
    "streakFreezeCount": 1,
    // ... other fields
  }
}
```

---

## Frontend Implementation

### 1. Data Models

**UserModel** - `app/lib/data/models/user_model.dart`

```dart
class UserModel {
  final int currentStreak;
  final int longestStreak;
  final int streakFreezeCount;
  // ...
}
```

**StreakInfo** - `app/lib/data/models/activity_model.dart`

```dart
class StreakInfo {
  final int previousStreak;
  final int currentStreak;
  final int longestStreak;
  final int streakFreezeCount;
  final String message;
  final String? info;
  
  // Helper methods
  bool get isMilestone; // True if 7, 14, 30, 60, 100, 365 days
  bool get usedFreeze;  // True if freeze was auto-used
  bool get wasReset;    // True if streak was reset
}
```

### 2. UI Widgets

#### StreakBadge

**Location:** `app/lib/ui/widgets/streak_badge.dart`

**Purpose:** Display current streak status

**Visibility:** Auto-hides when `currentStreak === 0`

**UI Elements:**
- Fire emoji (🔥)
- Current streak: "15 Day Streak"
- Longest streak: "Your longest: 28 days"
- Freeze count: Shield emoji (🛡️) with "x1" badge

**Styling:**
- Orange gradient background (#FF6B00 → #FF8C42)
- White text with shadow
- Rounded corners, subtle elevation

#### StreakFreezeShopItem

**Location:** `app/lib/ui/widgets/streak_freeze_shop_item.dart`

**Purpose:** Allow users to purchase Streak Freeze

**Visibility Conditions:**
- `currentStreak >= 3` (must have streak to unlock)
- `streakFreezeCount < 2` (not at max)

**Features:**
- Purchase confirmation dialog
- Loading state during API call
- Disabled states for max/insufficient balance
- Real-time balance validation

**Button States:**
- Enabled: "Buy for 500 EP" (Orange)
- Disabled: "Max Reached" or "Not Enough Points" (Gray)

#### StreakMilestoneDialog

**Location:** `app/lib/ui/widgets/streak_milestone_dialog.dart`

**Purpose:** Celebrate streak milestones

**Triggers:** Automatically shown after activity completion at:
- 7 days: "You're on fire!"
- 14 days: "Two weeks strong!"
- 30 days: "One month champion! 🏆"
- 60 days: "Incredible dedication!"
- 100 days: "Century club! 🎖️"
- 365 days: "ONE FULL YEAR! You're a legend! 👑"

**UI:**
- Large celebration emojis (🔥🎉🔥)
- Bold milestone text
- Custom message per milestone
- "Keep it up!" button

### 3. Integration Points

#### HomeScreen

**Location:** `app/lib/ui/screens/home/home_screen.dart`

**Layout Order:**
1. Home Header
2. **StreakBadge** ← Shows when streak > 0
3. **StreakFreezeShopItem** ← Shows when eligible
4. Arena/Stats Section
5. Quick Tasks

**Purchase Handler:**
```dart
Future<void> _handlePurchaseStreakFreeze(BuildContext context) {
  // Call UserRepository.purchaseStreakFreeze()
  // Show success/error snackbar
  // Refresh home data
}
```

#### ActiveSessionScreen

**Location:** `app/lib/ui/screens/tasks/active_session_screen.dart`

**Completion Flow:**
1. User completes task
2. Backend creates activity + updates streak
3. Check `streakInfo.isMilestone`
   - If true: Show `StreakMilestoneDialog` first
4. Show completion summary with:
   - Points earned
   - New wallet balance
   - Streak info notification (if applicable)

**Streak Notifications:**
- **Freeze Used**: Orange box with warning
- **Streak Reset**: Gray box with encouragement
- **No action**: Green box (optional)

---

## User Flows

### Daily Streak Flow

```
Day 1: User completes first task
  → currentStreak = 1
  → longestStreak = 1
  → lastActivityDate = Day 1

Day 2: User completes task
  → Check: daysDiff = 1 (consecutive)
  → currentStreak = 2
  → longestStreak = 2
  → lastActivityDate = Day 2

Day 3: User skips (no activity)
  → No update (streak remains 2)
  → lastActivityDate = Day 2

Day 4: User completes task
  → Check: daysDiff = 2 (missed Day 3)
  → Has Freeze? YES (count = 1)
  → Auto-use Freeze
  → currentStreak = 2 (maintained!)
  → streakFreezeCount = 0
  → Show notification: "Missed a day! Freeze used 🛡️"
  → lastActivityDate = Day 4

Day 5: User skips

Day 6: User skips

Day 7: User completes task
  → Check: daysDiff = 3 (missed Day 5, 6)
  → Has Freeze? NO
  → Reset streak
  → currentStreak = 1
  → Show notification: "Missed 2+ days. Streak reset 💪"
  → lastActivityDate = Day 7
```

### Freeze Purchase Flow

```
1. User has currentStreak >= 3
2. StreakFreezeShopItem becomes visible
3. User taps "Buy for 500 EP"
4. Confirmation dialog appears
5. User confirms
6. API Call: PUT /users/purchase-streak-freeze
7. Success:
   - Deduct 500 EP
   - Add 1 Freeze
   - Show success snackbar
   - Refresh home data
8. Error:
   - Show error message
   - Return to previous state
```

---

## Business Rules

### Streak Freeze

- **Cost**: 500 EP
- **Maximum**: 2 Freezes per user
- **Unlock**: Available when `currentStreak >= 3`
- **Bonus**: 1 Free Freeze awarded at 100-day milestone
- **Consumption**: Automatically used when user misses exactly 1 day
- **Not Used**: If user misses 2+ consecutive days

### Streak Reset Conditions

- Missing 2+ consecutive days without Freeze
- Missing 1 day when no Freeze available
- Manually (not implemented)

### Milestone Celebrations

**Trigger**: Automatically shown after activity completion when:
- `currentStreak` matches milestone value
- `message === 'STREAK_INCREASED'`

**List**: 7, 14, 30, 60, 100, 365 days

---

## Technical Considerations

### Timezone Handling

- All dates stored in **UTC**
- Comparison uses **start of day (00:00:00 UTC)**
- Frontend displays in **user's local timezone**

### Race Conditions

- Streak updates wrapped in database transaction
- `lastActivityDate` updated atomically with streak
- Prisma ensures consistency

### Performance

- Streak check: O(1) - simple date comparison
- No complex queries or aggregations
- Indexed `lastActivityDate` for future analytics

---

## Testing Checklist

### Backend

- [ ] First activity → Streak = 1
- [ ] Consecutive days → Streak increments
- [ ] Same day multiple tasks → No change
- [ ] 1 missed day + Freeze → Auto-use, maintain streak
- [ ] 1 missed day, no Freeze → Reset
- [ ] 2+ missed days → Reset (even with Freeze)
- [ ] 100-day milestone → Bonus Freeze
- [ ] Purchase validation (balance, max limit)

### Frontend

- [ ] Badge hidden when streak = 0
- [ ] Badge shows correct current/longest
- [ ] Freeze count displayed
- [ ] Shop item visibility (streak >= 3, count < 2)
- [ ] Purchase confirmation flow
- [ ] Milestone dialog triggers
- [ ] Completion dialog streak notifications

---

## Future Enhancements

### Potential Features

1. **Streak Calendar View**
   - Visual calendar showing activity history
   - Highlight streak days vs missed days

2. **Streak Reminders**
   - Push notification at 8pm if no activity today
   - "Don't break your 15-day streak!"

3. **Streak Recovery Grace Period**
   - 2-hour grace period after midnight
   - Allow late-night completions

4. **Social Features**
   - House leaderboard for longest streaks
   - Share milestone achievements

5. **Progressive Rewards**
   - Additional bonuses at longer milestones
   - Exclusive avatars for streak milestones

---

## Related Documentation

- [Home Screen Documentation](../screens/04_home_screen.md)
- [Task System](./TASK_SYSTEM.md)
- [API Integration Matrix](../screens/api_integration_matrix.md)
