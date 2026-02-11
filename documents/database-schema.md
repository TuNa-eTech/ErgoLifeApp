# Database Schema — PostgreSQL + Prisma

## Tổng quan

- **Database**: PostgreSQL >= 14
- **ORM**: Prisma 6.x
- **Models**: 11 bảng
- **Enums**: 5

---

## Enums

### AuthProvider
```
GOOGLE | APPLE
```

### RedemptionStatus
```
PENDING — Đã đổi, chưa sử dụng
USED    — Đã sử dụng
EXPIRED — Hết hạn (future)
```

### GiftRewardCategory
```
PRAISE     — Lời khen & Công nhận
PRIVILEGE  — Đặc quyền gia đình
EXPERIENCE — Trải nghiệm vui
MOTIVATION — Động viên & Tinh thần
```

### NotificationType
```
STREAK_REMINDER | STREAK_LOST | STREAK_MILESTONE | ACTIVITY_COMPLETED
HOUSE_INVITE | MEMBER_JOINED | LEADERBOARD_CHANGE | HOUSE_ACTIVITY
NEW_REWARD | ENOUGH_POINTS | REDEMPTION_APPROVED | REDEMPTION_REJECTED
GIFT_RECEIVED
WELCOME | APP_UPDATE
```

### NotificationPriority
```
LOW | MEDIUM | HIGH | URGENT
```

---

## Models

### User

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `firebaseUid` | String | ✅ | Firebase Auth UID (unique) |
| `provider` | AuthProvider | ✅ | GOOGLE hoặc APPLE |
| `email` | String | ❌ | Email từ provider |
| `displayName` | String | ❌ | Tên hiển thị |
| `avatarId` | Int | ❌ | ID avatar trong thư viện |
| `houseId` | UUID | ❌ | FK → House (null = chưa join) |
| `walletBalance` | Int | ✅ | Số EP hiện có (default: 0) |
| `fcmToken` | String | ❌ | Token cho Push Notification |
| `hasSeededTasks` | Boolean | ✅ | Đã seed tasks từ templates chưa |
| `currentStreak` | Int | ✅ | Chuỗi streak hiện tại (ngày) |
| `longestStreak` | Int | ✅ | Streak dài nhất từng đạt |
| `lastActivityDate` | DateTime | ❌ | Ngày hoạt động gần nhất |
| `streakFreezeCount` | Int | ✅ | Số streak freeze còn lại (0-2) |
| `preferredReminderTime` | DateTime | ❌ | Giờ nhắc nhở học từ patterns |
| `lastReminderSentAt` | DateTime | ❌ | Lần nhắc nhở gần nhất |
| `activityTimePattern` | JSON | ❌ | Phân bố hoạt động theo giờ |
| `leaderboardRank` | Int | ❌ | Thứ hạng hiện tại |

**Relations**: activities, rewards, redemptions, housesOwned, customTasks, notifications, giftsSent, giftsReceived

---

### House

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `name` | String | ✅ | Tên nhà (2-50 chars) |
| `inviteCode` | String | ✅ | Mã mời unique (auto-generated) |
| `isPersonal` | Boolean | ✅ | Nhà cá nhân (chỉ 1 người) |
| `createdById` | UUID | ✅ | FK → User tạo nhà |

**Relations**: members, activities, rewards, redemptions, giftTransactions

---

### TaskTemplate (CMS-managed)

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `metsValue` | Float | ✅ | Hệ số METs |
| `defaultDuration` | Int | ✅ | Thời gian mặc định (phút) |
| `icon` | String | ✅ | Material icon name |
| `animation` | String | ❌ | Lottie animation file |
| `color` | String | ✅ | Hex color code |
| `category` | String | ✅ | Phân loại (general, cleaning, v.v.) |
| `sortOrder` | Int | ✅ | Thứ tự sắp xếp |
| `isActive` | Boolean | ✅ | Đang hiển thị |

**Relations**: translations (TaskTemplateTranslation)

---

### TaskTemplateTranslation

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `templateId` | UUID | ✅ | FK → TaskTemplate |
| `locale` | String | ✅ | Mã ngôn ngữ ("en", "vi") |
| `name` | String | ✅ | Tên đã dịch |
| `description` | String | ❌ | Mô tả đã dịch |

**Unique**: (templateId, locale)

---

### CustomTask (User-created)

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `userId` | UUID | ✅ | FK → User sở hữu |
| `templateId` | UUID | ❌ | FK → TaskTemplate (null = custom) |
| `exerciseName` | String | ✅ | Tên task |
| `taskDescription` | String | ❌ | Mô tả |
| `durationMinutes` | Int | ✅ | Thời gian (phút) |
| `metsValue` | Float | ✅ | Hệ số METs (default: 3.5) |
| `icon` | String | ✅ | Material icon name |
| `animation` | String | ❌ | Lottie animation |
| `color` | String | ✅ | Hex color |
| `sortOrder` | Int | ✅ | Thứ tự |
| `isHidden` | Boolean | ✅ | Ẩn khỏi danh sách |
| `isFavorite` | Boolean | ✅ | Đánh dấu yêu thích |

---

### Activity

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `userId` | UUID | ✅ | FK → User thực hiện |
| `houseId` | UUID | ✅ | FK → House |
| `taskName` | String | ✅ | Tên task |
| `durationSeconds` | Int | ✅ | Thời gian làm (giây) |
| `metsValue` | Float | ✅ | Hệ số METs |
| `pointsEarned` | Int | ✅ | EP nhận được |
| `bonusMultiplier` | Float | ✅ | Hệ số bonus (default: 1.0) |
| `completedAt` | DateTime | ✅ | Thời điểm hoàn thành |

**Công thức EP**: `pointsEarned = (durationSeconds / 60) × metsValue × 10 × bonusMultiplier`

---

### Reward (User-created coupon)

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `houseId` | UUID | ✅ | FK → House |
| `creatorId` | UUID | ✅ | FK → User tạo |
| `title` | String | ✅ | Tên coupon (2-50 chars) |
| `cost` | Int | ✅ | Giá EP (100-10000) |
| `icon` | String | ✅ | Icon name |
| `description` | String | ❌ | Mô tả |
| `isActive` | Boolean | ✅ | Đang hiển thị |

---

### Redemption

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `userId` | UUID | ✅ | FK → User đổi |
| `rewardId` | UUID | ✅ | FK → Reward |
| `houseId` | UUID | ✅ | FK → House |
| `rewardTitle` | String | ✅ | Snapshot tên reward lúc đổi |
| `pointsSpent` | Int | ✅ | EP đã trừ |
| `status` | RedemptionStatus | ✅ | PENDING / USED / EXPIRED |
| `redeemedAt` | DateTime | ✅ | Thời điểm đổi |
| `usedAt` | DateTime | ❌ | Thời điểm sử dụng |

---

### Notification

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `userId` | UUID | ✅ | FK → User nhận |
| `type` | NotificationType | ✅ | Loại thông báo |
| `priority` | NotificationPriority | ✅ | Mức ưu tiên |
| `title` | String | ✅ | Tiêu đề |
| `body` | String | ✅ | Nội dung |
| `imageUrl` | String | ❌ | URL ảnh đính kèm |
| `data` | JSON | ❌ | Metadata (houseId, activityId, v.v.) |
| `actionUrl` | String | ❌ | Deep link (ergolife://house/123) |
| `isRead` | Boolean | ✅ | Đã đọc |
| `isSent` | Boolean | ✅ | Đã gửi push |
| `sentAt` | DateTime | ❌ | Thời điểm gửi push |
| `readAt` | DateTime | ❌ | Thời điểm đọc |
| `scheduledFor` | DateTime | ❌ | Lên lịch gửi sau |

---

### GiftReward (App-managed, seeded)

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `key` | String | ✅ | Unique key (VD: "gold_star") |
| `category` | GiftRewardCategory | ✅ | Phân loại quà |
| `icon` | String | ✅ | Emoji icon |
| `cost` | Int | ✅ | Giá EP |
| `sortOrder` | Int | ✅ | Thứ tự |
| `isActive` | Boolean | ✅ | Đang hiển thị |

**Relations**: translations, transactions

---

### GiftRewardTranslation

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `rewardId` | UUID | ✅ | FK → GiftReward |
| `locale` | String | ✅ | Mã ngôn ngữ |
| `name` | String | ✅ | Tên đã dịch |
| `description` | String | ❌ | Mô tả đã dịch |

---

### GiftTransaction

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `id` | UUID | ✅ | Primary key |
| `senderId` | UUID | ✅ | FK → User gửi |
| `receiverId` | UUID | ✅ | FK → User nhận |
| `houseId` | UUID | ✅ | FK → House |
| `rewardId` | UUID | ✅ | FK → GiftReward |
| `rewardName` | String | ✅ | Snapshot tên quà |
| `rewardIcon` | String | ✅ | Snapshot icon |
| `pointsSpent` | Int | ✅ | EP đã trừ |
| `message` | String | ❌ | Lời nhắn (tối đa 100 ký tự) |
| `createdAt` | DateTime | ✅ | Thời điểm gửi |

---

## Migration Commands

```bash
yarn prisma generate          # Tạo Prisma client
yarn prisma migrate dev       # Chạy migration (dev)
yarn prisma migrate deploy    # Apply migration (production)
yarn prisma migrate reset     # Reset database (dev only)
yarn prisma db seed           # Seed data
```
