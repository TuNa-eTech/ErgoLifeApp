# Notification Feature Documentation

## Overview

The ErgoLifeApp notification system provides a comprehensive push notification infrastructure with personalized timing, in-app notification management, and seamless integration across backend and Flutter mobile app.

## Architecture

### System Components

```mermaid
graph TB
    subgraph "Flutter Mobile App"
        UI[Notification UI]
        Bloc[NotificationBloc]
        Repo[NotificationRepository]
        FCM[FcmService]
        Local[LocalNotificationService]
    end
    
    subgraph "Backend API"
        API[Notifications Controller]
        Service[NotificationsService]
        Cron[Streak Reminder Cron]
        Pattern[Activity Pattern Service]
        FcmBackend[FCM Service]
    end
    
    subgraph "External Services"
        Firebase[Firebase Cloud Messaging]
        DB[(PostgreSQL Database)]
    end
    
    UI --> Bloc
    Bloc --> Repo
    Repo --> API
    API --> Service
    Service --> DB
    Service --> FcmBackend
    FcmBackend --> Firebase
    Firebase --> FCM
    FCM --> Local
    Local --> UI
    
    Cron --> Pattern
    Pattern --> DB
    Cron --> Service
```

### Technology Stack

**Backend:**
- NestJS (Node.js framework)
- Prisma ORM
- PostgreSQL database
- Firebase Admin SDK
- Node-cron for scheduled tasks

**Mobile:**
- Flutter/Dart
- BLoC state management
- firebase_messaging package
- flutter_local_notifications
- dio for HTTP requests

## Features

### 1. Push Notifications via FCM
- Real-time push notifications to mobile devices
- Support for Android and iOS platforms
- Background and foreground message handling
- Custom notification channels and priorities

### 2. Personalized Reminder Timing
- ML-based activity pattern analysis
- Automatic optimal reminder time calculation
- Hourly checks with smart skip logic
- Fallback to default time (20:00) for new users

### 3. In-App Notification Center
- Paginated notification list
- Unread count badge
- Mark as read functionality
- Delete notifications
- Real-time updates via BLoC

### 4. Notification Types

| Type | Description | Priority | Use Case |
|------|-------------|----------|----------|
| `STREAK_REMINDER` | Daily activity reminder | High | Sent at personalized time |
| `STREAK_LOST` | Streak broken notification | High | When user misses a day |
| `STREAK_MILESTONE` | Achievement milestone | Medium | 7, 30, 100 day streaks |
| `ACTIVITY_COMPLETED` | Task completion | Low | When user completes task |
| `HOUSE_INVITE` | House invitation | High | Social feature |
| `MEMBER_JOINED` | New house member | Medium | Social feature |
| `LEADERBOARD_CHANGE` | Rank update | Low | Gamification |
| `NEW_REWARD` | New reward available | Medium | Rewards system |
| `REDEMPTION_APPROVED` | Reward redeemed | High | Rewards system |
| `WELCOME` | Welcome message | Medium | Onboarding |
| `APP_UPDATE` | App update available | Low | System |

## Database Schema

### Notification Table

```prisma
model Notification {
  id            String              @id @default(cuid())
  userId        String
  type          NotificationType
  priority      NotificationPriority
  title         String
  body          String
  imageUrl      String?
  actionUrl     String?
  actionData    Json?
  isRead        Boolean             @default(false)
  isSent        Boolean             @default(false)
  
  relatedUserId   String?
  relatedUser     User?             @relation("RelatedUser", fields: [relatedUserId], references: [id])
  
  readAt        DateTime?
  sentAt        DateTime?
  createdAt     DateTime            @default(now())
  
  user          User                @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([userId, isRead])
  @@index([userId, createdAt])
  @@index([isSent])
}
```

### User Fields (for Personalized Timing)

```prisma
model User {
  // ... existing fields
  
  // Notification preferences
  fcmToken                String?
  preferredReminderTime   Int?      @default(20) // Hour of day (0-23)
  lastReminderSentAt      DateTime?
  activityTimePattern     Json?     // Hourly activity distribution
}
```

## Backend API

### Endpoints

#### GET `/api/notifications`
Get user's notifications (paginated)

**Query Parameters:**
- `page` (number, default: 1)
- `limit` (number, default: 20)
- `unreadOnly` (boolean, default: false)

**Response:**
```typescript
{
  notifications: Notification[],
  total: number,
  page: number,
  limit: number,
  hasMore: boolean
}
```

#### GET `/api/notifications/unread-count`
Get unread notification count

**Response:**
```typescript
{
  count: number
}
```

#### PATCH `/api/notifications/:id/read`
Mark notification as read

**Response:** Updated notification

#### PATCH `/api/notifications/read-all`
Mark all notifications as read

**Response:**
```typescript
{
  updated: number
}
```

#### DELETE `/api/notifications/:id`
Delete notification

**Response:** 204 No Content

#### POST `/api/notifications/test` (Development Only)
Send test notification

**Body:**
```typescript
{
  userId: string,
  title: string,
  body: string
}
```

### Services

#### NotificationsService
Core notification CRUD operations and business logic.

**Key Methods:**
- `create()` - Create notification and optionally send push
- `findAll()` - Get paginated notifications
- `getUnreadCount()` - Count unread notifications
- `markAsRead()` - Mark single notification as read
- `markAllAsRead()` - Mark all user's notifications as read
- `delete()` - Delete notification

#### FcmService
Firebase Cloud Messaging integration.

**Key Methods:**
- `send()` - Send to single device
- `sendMulticast()` - Send to multiple devices
- `sendToTopic()` - Send to topic subscribers
- `subscribeToTopic()` - Subscribe device to topic
- `unsubscribeFromTopic()` - Unsubscribe from topic

#### StreakReminderService
Automated streak reminder system with personalized timing.

**Features:**
- Runs hourly via cron job
- Checks each user's preferred reminder time
- Skips if user already active today
- Skips if reminder already sent today
- Creates notification and sends push

#### ActivityPatternService
ML-based activity pattern analysis for optimal reminder timing.

**Features:**
- Analyzes 30-day activity history
- Calculates hourly activity distribution
- Determines optimal reminder time
- Runs daily via cron job
- Stores pattern in user's `activityTimePattern` field

**Algorithm:**
```typescript
// 1. Get activities from last 30 days
// 2. Create 24-hour distribution map
// 3. Find hour with highest activity
// 4. Set as preferredReminderTime
// 5. Update user record
```

## Flutter Implementation

### State Management (BLoC)

#### NotificationBloc

**Events:**
- `LoadNotifications` - Load first page
- `LoadMoreNotifications` - Load next page
- `RefreshNotifications` - Refresh from page 1
- `MarkAsRead(id)` - Mark single as read
- `MarkAllAsRead` - Mark all as read
- `DeleteNotification(id)` - Delete notification
- `RefreshUnreadCount` - Update badge count

**States:**
- `NotificationInitial` - Initial state
- `NotificationLoading` - Loading data
- `NotificationLoaded` - Data loaded successfully
  - `notifications`: List of notifications
  - `unreadCount`: Badge count
  - `currentPage`: Current page number
  - `hasMore`: More data available
- `NotificationError` - Error state

**State Machine:**
```
Initial → Loading → Loaded
                  ↓
                Error
                  
Loaded → Loading → Loaded (on refresh/load more)
```

### Services

#### FcmService (Flutter)
Manages FCM token and message handling.

**Responsibilities:**
- Get and cache FCM token
- Register token with backend
- Handle foreground messages
- Configure notification tap handling
- Auto-request permissions

#### LocalNotificationService
Displays notifications when app is in foreground.

**Features:**
- Custom notification channels
- Sound and vibration
- Notification tap navigation
- Badge count updates

### UI Components

#### NotificationCenterScreen
Main notification list screen.

**Features:**
- Pull-to-refresh
- Infinite scroll pagination
- Empty state
- Error handling
- Mark all as read button
- Navigate to related content on tap

#### NotificationItem
Single notification list item widget.

**Displays:**
- Notification icon (based on type)
- Title and body
- Relative timestamp (using timeago)
- Read/unread indicator
- Swipe-to-delete action

#### NotificationBadge
Unread count badge for navigation bar.

**Features:**
- Real-time count updates via BLoC
- Hide when count is 0
- Positioned on Profile tab icon

## Testing

### Backend Unit Tests

**Test Coverage: 54 tests passing**

- FcmService: 15 tests
- NotificationsService: 15 tests
- NotificationsController: 7 tests
- StreakReminderService: 9 tests
- ActivityPatternService: 8 tests

**Coverage:** >80% on all services

### Flutter Unit Tests

**Test Coverage: 23 tests passing (100%)**

- NotificationBloc: 23 tests
  - LoadNotifications (4 tests)
  - LoadMoreNotifications (3 tests)
  - MarkAsRead (3 tests)
  - MarkAllAsRead (3 tests)
  - DeleteNotification (3 tests)
  - RefreshUnreadCount (3 tests)
  - Edge Cases (4 tests)

## Configuration

### Backend (.env)

```bash
# Firebase Admin SDK
FIREBASE_CREDENTIALS_PATH=./ergolife-firebase-adminsdk.json

# Database
DATABASE_URL="postgresql://user:password@localhost:4433/ergolife_db?schema=public"

# Cron Jobs
STREAK_REMINDER_CRON="0 * * * *"  # Hourly
PATTERN_ANALYSIS_CRON="0 2 * * *" # Daily at 2 AM
```

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

<!-- FCM Receiver -->
<receiver android:exported="false" android:name="com.google.firebase.iid.FirebaseInstanceIdReceiver"/>

<!-- Notification Icon -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />

<!-- Notification Channel -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="ergolife_notifications" />
```

### iOS (ios/Runner/Info.plist)

```xml
<!-- Background modes -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>

<!-- Firebase messaging -->
<key>FirebaseMessagingAutoInitEnabled</key>
<true/>
```

## Deployment Checklist

### Backend
- [ ] Configure Firebase service account JSON
- [ ] Set environment variables
- [ ] Run database migrations
- [ ] Verify cron jobs are scheduled
- [ ] Test FCM sending manually

### Mobile App
- [ ] Configure Firebase project (Android + iOS)
- [ ] Add google-services.json (Android)
- [ ] Add GoogleService-Info.plist (iOS)
- [ ] Request notification permissions
- [ ] Test push notifications on real devices
- [ ] Verify deep linking navigation

## Troubleshooting

### Backend Issues

**Firebase initialization error:**
```
Error: The default Firebase app does not exist
```
**Solution:** Ensure `FirebaseService.onModuleInit()` runs before `FcmService.onModuleInit()`. FcmService should implement `OnModuleInit` and initialize messaging there, not in constructor.

**Cron jobs not running:**
- Check cron expression syntax
- Verify server timezone
- Check logs for errors

### Mobile Issues

**FCM token not registered:**
- Check internet connection
- Verify Firebase configuration files
- Check backend API endpoint

**Notifications not showing:**
- Check notification permissions
- Verify notification channel configuration (Android)
- Check Firebase console for send errors

**Background notifications not working:**
- Verify background modes (iOS)
- Check if app is in battery optimization (Android)
- Ensure background message handler is registered

## Performance Considerations

### Database Optimization
- Indexed on `(userId, isRead)` for fast unread queries
- Indexed on `(userId, createdAt)` for pagination
- Indexed on `isSent` for cron job queries

### Caching Strategy
- FCM token cached in Flutter app
- Unread count cached in BLoC state
- Notification list paginated (20 items/page)

### Batch Operations
- `markAllAsRead()` uses single UPDATE query
- `sendMulticast()` sends to up to 500 devices at once
- Cron jobs process users in batches

## Future Enhancements

### Planned Features
- [ ] Notification preferences (mute types, quiet hours)
- [ ] Rich notifications with images
- [ ] Notification grouping
- [ ] Push notification analytics
- [ ] A/B testing for reminder timing

### Optimization Opportunities
- Implement notification read receipts
- Add notification expiration
- Implement notification priority queue
- Add notification templates
- Support for multiple FCM tokens per user

## References

### Documentation
- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [flutter_local_notifications Package](https://pub.dev/packages/flutter_local_notifications)
- [Prisma Notifications Guide](https://www.prisma.io/docs/guides/database/advanced-database-tasks/notifications)

### Related Files

**Backend:**
- [Notification Prisma Schema](file:///Users/anhtu/MySpace/Personal%20Project/ErgoLifeApp/backend/prisma/schema.prisma)
- [NotificationsService](file:///Users/anhtu/MySpace/Personal%20Project/ErgoLifeApp/backend/src/notifications/notifications.service.ts)
- [FcmService](file:///Users/anhtu/MySpace/Personal%20Project/ErgoLifeApp/backend/src/firebase/fcm.service.ts)
- [StreakReminderService](file:///Users/anhtu/MySpace/Personal%20Project/ErgoLifeApp/backend/src/notifications/streak-reminder.service.ts)

**Flutter:**
- [NotificationBloc](file:///Users/anhtu/MySpace/Personal%20Project/ErgoLifeApp/app/lib/blocs/notification/notification_bloc.dart)
- [NotificationRepository](file:///Users/anhtu/MySpace/Personal%20Project/ErgoLifeApp/app/lib/data/repositories/notification_repository.dart)
- [NotificationCenterScreen](file:///Users/anhtu/MySpace/Personal%20Project/ErgoLifeApp/app/lib/presentation/screens/notification/notification_center_screen.dart)
- [FcmService (Flutter)](file:///Users/anhtu/MySpace/Personal%20Project/ErgoLifeApp/app/lib/services/fcm_service.dart)

## Support

For issues or questions:
- Check logs: Backend uses NestJS Logger, Flutter uses AppLogger
- Review test files for usage examples
- Consult Firebase Console for FCM diagnostics
