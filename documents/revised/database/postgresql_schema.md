# PostgreSQL Schema (Prisma)

## Overview
Schema định nghĩa cho Prisma ORM, sử dụng với NestJS backend.

---

## Complete Schema

```prisma
// ===========================================
// ENUMS
// ===========================================

enum AuthProvider {
  GOOGLE
  APPLE
}

enum RedemptionStatus {
  PENDING   // Đã đổi, chưa sử dụng
  USED      // Đã sử dụng
  EXPIRED   // Hết hạn (future feature)
}

// ===========================================
// MODELS
// ===========================================

model User {
  id           String   @id @default(uuid())
  firebaseUid  String   @unique @map("firebase_uid")
  provider     AuthProvider
  email        String?  @unique
  displayName  String?  @map("display_name")
  avatarId     Int?     @map("avatar_id")
  
  // House relationship
  houseId      String?  @map("house_id")
  house        House?   @relation("HouseMembers", fields: [houseId], references: [id])
  
  // Economy
  walletBalance Int     @default(0) @map("wallet_balance")
  
  // Push notifications
  fcmToken     String?  @map("fcm_token")
  
  // Timestamps
  createdAt    DateTime @default(now()) @map("created_at")
  updatedAt    DateTime @updatedAt @map("updated_at")
  
  // Relations
  activities   Activity[]
  rewards      Reward[]     @relation("RewardCreator")
  redemptions  Redemption[]
  housesOwned  House[]      @relation("HouseOwner")

  @@map("users")
}

model House {
  id          String   @id @default(uuid())
  name        String
  inviteCode  String   @unique @default(cuid()) @map("invite_code")
  
  // Owner
  createdById String   @map("created_by")
  createdBy   User     @relation("HouseOwner", fields: [createdById], references: [id])
  
  // Timestamps
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")
  
  // Relations
  members     User[]   @relation("HouseMembers")
  activities  Activity[]
  rewards     Reward[]
  redemptions Redemption[]

  @@map("houses")
}

model Activity {
  id              String   @id @default(uuid())
  
  // References
  userId          String   @map("user_id")
  user            User     @relation(fields: [userId], references: [id])
  houseId         String   @map("house_id")
  house           House    @relation(fields: [houseId], references: [id])
  
  // Task details
  taskName        String   @map("task_name")
  durationSeconds Int      @map("duration_seconds")
  metsValue       Float    @map("mets_value")
  
  // Points
  pointsEarned    Int      @map("points_earned")
  bonusMultiplier Float    @default(1.0) @map("bonus_multiplier")
  
  // Completion
  completedAt     DateTime @default(now()) @map("completed_at")

  @@index([houseId, completedAt])
  @@index([userId, completedAt])
  @@map("activities")
}

model Reward {
  id          String   @id @default(uuid())
  
  // References
  houseId     String   @map("house_id")
  house       House    @relation(fields: [houseId], references: [id])
  creatorId   String   @map("creator_id")
  creator     User     @relation("RewardCreator", fields: [creatorId], references: [id])
  
  // Reward details
  title       String
  cost        Int
  icon        String   @default("gift")
  description String?
  
  // Status
  isActive    Boolean  @default(true) @map("is_active")
  
  // Timestamps
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")
  
  // Relations
  redemptions Redemption[]

  @@index([houseId, isActive])
  @@map("rewards")
}

model Redemption {
  id          String           @id @default(uuid())
  
  // References
  userId      String           @map("user_id")
  user        User             @relation(fields: [userId], references: [id])
  rewardId    String           @map("reward_id")
  reward      Reward           @relation(fields: [rewardId], references: [id])
  houseId     String           @map("house_id")
  house       House            @relation(fields: [houseId], references: [id])
  
  // Snapshot at redemption time
  rewardTitle String           @map("reward_title")
  pointsSpent Int              @map("points_spent")
  
  // Status
  status      RedemptionStatus @default(PENDING)
  
  // Timestamps
  redeemedAt  DateTime         @default(now()) @map("redeemed_at")
  usedAt      DateTime?        @map("used_at")

  @@index([userId, redeemedAt])
  @@index([houseId, redeemedAt])
  @@map("redemptions")
}
```

---

## Field Descriptions

### User

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | ✅ | Primary key |
| firebaseUid | String | ✅ | Firebase Auth UID (unique) |
| provider | Enum | ✅ | GOOGLE hoặc APPLE |
| email | String | ❌ | Email từ provider |
| displayName | String | ❌ | Tên hiển thị do user đặt |
| avatarId | Int | ❌ | ID của avatar trong thư viện |
| houseId | UUID | ❌ | FK đến House (null = chưa join house) |
| walletBalance | Int | ✅ | Số điểm hiện có (default: 0) |
| fcmToken | String | ❌ | Token cho Push Notification |

### House

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | ✅ | Primary key |
| name | String | ✅ | Tên nhà (2-50 chars) |
| inviteCode | String | ✅ | Mã mời unique (auto-generated) |
| createdById | UUID | ✅ | FK đến User tạo nhà |

### Activity

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | ✅ | Primary key |
| userId | UUID | ✅ | FK đến User thực hiện |
| houseId | UUID | ✅ | FK đến House (denormalized) |
| taskName | String | ✅ | Tên việc (VD: "Hút bụi") |
| durationSeconds | Int | ✅ | Thời gian làm (seconds) |
| metsValue | Float | ✅ | Hệ số METs của task |
| pointsEarned | Int | ✅ | Điểm nhận được |
| bonusMultiplier | Float | ✅ | Hệ số bonus (default: 1.0) |
| completedAt | DateTime | ✅ | Thời điểm hoàn thành |

### Reward

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | ✅ | Primary key |
| houseId | UUID | ✅ | FK đến House |
| creatorId | UUID | ✅ | FK đến User tạo |
| title | String | ✅ | Tên coupon (2-50 chars) |
| cost | Int | ✅ | Giá (100-10000) |
| icon | String | ✅ | Icon name (default: "gift") |
| description | String | ❌ | Mô tả chi tiết |
| isActive | Boolean | ✅ | Còn hiển thị trong shop? |

### Redemption

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | ✅ | Primary key |
| userId | UUID | ✅ | FK đến User đổi |
| rewardId | UUID | ✅ | FK đến Reward |
| houseId | UUID | ✅ | FK đến House (denormalized) |
| rewardTitle | String | ✅ | Snapshot tên reward |
| pointsSpent | Int | ✅ | Số điểm đã trừ |
| status | Enum | ✅ | PENDING / USED / EXPIRED |
| redeemedAt | DateTime | ✅ | Thời điểm đổi |
| usedAt | DateTime | ❌ | Thời điểm đánh dấu used |

---

## Validation Rules

### User
```typescript
displayName: z.string().min(2).max(30).optional()
avatarId: z.number().min(1).max(20).optional()
```

### House
```typescript
name: z.string().min(2).max(50)
// Max 4 members per house (enforced in service layer)
```

### Activity
```typescript
taskName: z.string().min(1).max(50)
durationSeconds: z.number().min(60).max(7200) // 1 min - 2 hours
metsValue: z.number().min(1).max(10)
```

### Reward
```typescript
title: z.string().min(2).max(50)
cost: z.number().min(100).max(10000)
icon: z.string().min(1).max(30)
```

---

## Migration Commands

```bash
# Generate Prisma client
npx prisma generate

# Create migration
npx prisma migrate dev --name init

# Apply migration to production
npx prisma migrate deploy

# Reset database (development only)
npx prisma migrate reset
```
