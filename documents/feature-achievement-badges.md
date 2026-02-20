# 🏅 Feature: Achievement & Badge System

## Tổng quan

Hệ thống **Achievement & Badge** cho phép user sưu tập huy hiệu khi đạt các milestone. Tạo sense of progression dài hạn, khiến user không muốn bỏ cuộc vì đã "đầu tư" nhiều vào account.

## Vấn đề hiện tại

- Streak milestones chỉ gửi notification rồi hết — không lưu lại gì
- Không có sense of progression dài hạn ngoài con số EP
- Profile chỉ hiện stats khô khan — không có gì để "khoe"
- User mới và user cũ không có sự khác biệt trải nghiệm

---

## Thiết kế hệ thống

### Cấu trúc Tier

```
Achievement Category
  └── Achievement (VD: "Streak Master")
        └── Tier 1: Bronze (7 ngày streak)
        └── Tier 2: Silver (30 ngày streak)
        └── Tier 3: Gold (100 ngày streak)
        └── Tier 4: Diamond (365 ngày streak)
```

### Danh sách Achievements (30+ ban đầu)

#### 🔥 Streak Category

| Achievement | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|------------|--------|--------|--------|--------|
| Streak Master | 7 ngày | 30 ngày | 100 ngày | 365 ngày |
| Perfect Week | 1 tuần perfect | 4 tuần | 12 tuần | 52 tuần |
| Comeback Kid | Khôi phục streak 1 lần | 3 lần | 10 lần | — |

#### 💪 Activity Category

| Achievement | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|------------|--------|--------|--------|--------|
| First Timer | Hoàn thành 1 activity | — | — | — |
| Dedicated | 10 activities | 50 | 200 | 1000 |
| Marathon Runner | 30 phút liên tục | 60 phút | 90 phút | 120 phút |
| Early Bird | 5 activities trước 8am | 20 | 50 | 100 |
| Night Owl | 5 activities sau 9pm | 20 | 50 | 100 |
| Category Explorer | Tập 3 categories | 5 | 8 | tất cả |

#### ⭐ EP Category

| Achievement | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|------------|--------|--------|--------|--------|
| EP Earner | 1,000 EP | 10,000 | 50,000 | 100,000 |
| Big Day | 500 EP trong 1 ngày | 1,000 | 2,000 | 5,000 |
| EP Machine | 100 EP/activity avg (10 lần) | 200 avg | 300 avg | 500 avg |

#### 🏠 Social Category

| Achievement | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|------------|--------|--------|--------|--------|
| House Builder | Tạo 1 house | — | — | — |
| Gift Giver | Gửi 1 quà | 10 quà | 50 quà | 100 quà |
| Top Dog | #1 leaderboard 1 tháng | 3 tháng | 6 tháng | 12 tháng |
| Team Player | House streak 7 ngày | 30 | 60 | 100 |
| Recruiter | Mời 1 người | 3 | 5 | 10 |

#### ❤️ Health Category

| Achievement | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|------------|--------|--------|--------|--------|
| Heart Pumper | 1 session CARDIO zone | 10 | 50 | 100 |
| Calorie Crusher | 100 kcal/session | 200 | 500 | 1000 |
| Step Master | 5,000 steps/ngày (7 ngày) | 10,000 | 15,000 | 20,000 |

#### 🌟 Special / Rare (không tier)

| Achievement | Điều kiện |
|------------|-----------|
| OG Member | Tham gia trong tháng đầu tiên |
| Perfectionist | 30 Perfect Days liên tiếp |
| Variety King | Hoàn thành 20 tasks khác nhau |
| Generous Soul | Gửi quà cho tất cả members trong house |
| Weekend Warrior | Tập cả Thứ 7 và Chủ nhật (4 tuần liên tiếp) |

---

## Level / Rank System

Dựa trên **tổng EP tích lũy** (lifetime):

| Level | Tên | EP cần | Badge Icon |
|-------|-----|--------|------------|
| 1 | Beginner | 0 | 🥉 |
| 2 | Active | 1,000 | 🏃 |
| 3 | Dedicated | 5,000 | 💪 |
| 4 | Champion | 15,000 | 🏆 |
| 5 | Master | 50,000 | ⭐ |
| 6 | Legend | 100,000 | 👑 |
| 7 | Immortal | 500,000 | 💎 |

- Level hiện trên profile avatar (badge overlay)
- Level hiện trên leaderboard entries
- Level up → animation celebration + notification

---

## UI/UX

### Achievement Screen (Tab mới hoặc trong Profile)

- **Grid layout** — mỗi badge là 1 card hình tròn
- Badge chưa unlock: grayscale + lock icon
- Badge đã unlock: full color + sparkle animation
- Tap badge → detail popup (mô tả, ngày unlock, tier progress bar)
- Filter: All / Unlocked / Locked, theo Category

### Badge Showcase (Profile)

- Khu vực "**Pinned Badges**" — user chọn tối đa 3 badges yêu thích để hiện trên profile
- Hiển thị cạnh avatar khi xuất hiện trên leaderboard, house members
- **Level badge** luôn hiển thị bên cạnh tên

### Unlock Animation

- Full-screen overlay khi unlock badge mới
- Lottie animation: badge rơi xuống + glow effect
- Sound effect (optional — có toggle)
- CTA: "Share" hoặc "View Collection"

### Progress Tracking

- Mỗi achievement có progress bar (VD: "42/50 activities")
- "Almost there!" label khi đạt 80%+
- Push notification khi gần đạt: "Bạn chỉ còn 3 activities nữa là unlock 'Dedicated Silver'!"

---

## Data Model

### Backend — Schema

```
model Achievement {
  id          String @id @default(uuid())
  key         String @unique           // "streak_master"
  category    String                    // "streak"
  name        String                    // "Streak Master"
  nameVi      String?                   // "Bậc thầy Streak"
  description String
  descVi      String?
  icon        String                    // emoji or asset name
  maxTier     Int    @default(4)
  isSpecial   Boolean @default(false)   // rare, no tier

  tiers   AchievementTier[]
  unlocks UserAchievement[]
}

model AchievementTier {
  id            String @id @default(uuid())
  achievementId String
  tier          Int                    // 1, 2, 3, 4
  tierName      String                 // "Bronze", "Silver"...
  threshold     Int                    // giá trị cần đạt
  epReward      Int    @default(0)     // EP thưởng khi unlock

  achievement Achievement @relation(...)
  @@unique([achievementId, tier])
}

model UserAchievement {
  id            String   @id @default(uuid())
  userId        String
  achievementId String
  currentTier   Int      @default(0)   // 0 = chưa unlock
  progress      Int      @default(0)   // giá trị hiện tại
  unlockedAt    DateTime?
  updatedAt     DateTime @updatedAt

  user        User        @relation(...)
  achievement Achievement @relation(...)
  @@unique([userId, achievementId])
}
```

### API Endpoints

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/achievements` | Danh sách tất cả achievements |
| GET | `/achievements/me` | Progress của user hiện tại |
| GET | `/achievements/me/recent` | Badges mới unlock gần đây |
| PUT | `/achievements/me/pinned` | Cập nhật pinned badges |
| POST | `/achievements/check` | Internal: check & unlock (gọi sau activity) |

### Flutter — Model

```dart
class AchievementModel extends Equatable {
  final String id;
  final String key;
  final String category;
  final String name;
  final String? nameVi;
  final String description;
  final String icon;
  final int maxTier;
  final bool isSpecial;
  final List<AchievementTierModel> tiers;
  // User progress (nullable nếu chưa có)
  final int currentTier;
  final int progress;
  final DateTime? unlockedAt;

  bool get isUnlocked => currentTier > 0;
  bool get isMaxTier => currentTier >= maxTier;
  AchievementTierModel? get nextTier =>
      tiers.where((t) => t.tier > currentTier)
           .firstOrNull;
  double get progressPercent => nextTier != null
      ? progress / nextTier!.threshold : 1.0;
}
```

---

## Logic tích hợp

### Achievement Checker Service (Backend)

Chạy sau mỗi event quan trọng:

```
Sau createActivity():
  → Check: Dedicated (total activities)
  → Check: Marathon Runner (duration)
  → Check: EP Earner (total EP)
  → Check: Big Day (daily EP)
  → Check: Early Bird / Night Owl (time)
  → Check: Category Explorer (categories)
  → Check: Heart Pumper (HR zone)
  → Check: Calorie Crusher (calories)

Sau updateStreak():
  → Check: Streak Master (streak days)
  → Check: Comeback Kid (streak restores)

Sau sendGift():
  → Check: Gift Giver (gift count)

Sau joinHouse() / createHouse():
  → Check: House Builder, Recruiter

Sau updateLeaderboard() (monthly):
  → Check: Top Dog (#1 position)
```

### Notification khi unlock

```
Type: ACHIEVEMENT_UNLOCKED
Title: "🏅 Huy hiệu mới!"
Body: "Bạn đã đạt 'Streak Master Silver'
       — 30 ngày streak! +200 EP"
```

---

## Metric đo lường thành công

| Metric | Target |
|--------|--------|
| D30 Retention | +25% |
| Profile views/user | +50% |
| Avg EP earned/week | +20% |
| Social shares | +40% |
