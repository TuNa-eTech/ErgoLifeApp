# 📅 Feature: Daily Goal Rings

## Tổng quan

Hệ thống **Daily Goal Rings** cho phép user đặt mục tiêu hàng ngày với 3 chỉ số chính, hiển thị dạng vòng tròn tiến trình (giống Apple Activity Rings). Đây là tính năng cốt lõi để tạo lý do mở app mỗi ngày.

## Vấn đề hiện tại

- App chỉ có streak nhị phân (có/không hoàn thành 1 activity)
- User không có mục tiêu cụ thể mỗi ngày → thiếu motivation
- Không có cách đo lường "hôm nay tập đủ chưa"
- Sau 2-3 tuần sử dụng, user dễ quên app vì không có daily target

---

## Thiết kế tính năng

### 3 Goal Rings

| Ring | Chỉ số | Default | Đơn vị | Màu |
|------|--------|---------|--------|-----|
| 🔴 EP Ring | Tổng EP kiếm được | 500 EP | EP | Đỏ cam (#FF6B35) |
| 🟢 Duration Ring | Tổng thời gian tập | 30 phút | Phút | Xanh lá (#4CAF50) |
| 🔵 Activity Ring | Số lượng activities | 3 | Lần | Xanh dương (#2196F3) |

### Cấu hình mục tiêu

- User tự điều chỉnh target cho mỗi ring trong **Settings**
- Min/Max constraints:
  - EP: 100 – 5000 EP
  - Duration: 10 – 120 phút
  - Activities: 1 – 10 lần
- Hệ thống **suggest** target dựa trên average 7 ngày gần nhất

### Completion Flow

```
User hoàn thành activity
  → Cập nhật ring progress real-time
  → Ring đạt 100% → Animation "ring close" + haptic
  → Cả 3 rings close → "Perfect Day" celebration 🎉
  → "Perfect Day" 7 ngày liên tiếp → Bonus 500 EP + badge
```

---

## UI/UX

### Home Screen — Goal Rings Card

- Vị trí: phía trên Quick Tasks section trên Home Screen
- Hiển thị 3 vòng tròn đồng tâm (ngoài → trong: EP, Duration, Activity)
- Bên cạnh rings: text hiện tiến độ (VD: "420/500 EP")
- Tap vào rings → mở detail card với breakdown từng ring

### Ring Animation

- Rings fill smoothly khi có activity mới (animate từ % cũ → % mới)
- Khi ring đạt 100%: pulse animation + checkmark icon
- Khi cả 3 hoàn thành: confetti burst + "Perfect Day!" toast
- Ring vượt 100%: hiển thị overflow (VD: 150%) với gradient sáng hơn

### Notification Nudges

- **Evening reminder** (nếu chưa đạt): "Bạn chỉ còn thiếu 80 EP để hoàn thành mục tiêu hôm nay! 💪"
- **Congratulations** (khi đạt): "Chúc mừng! Bạn đã hoàn thành tất cả mục tiêu hôm nay! 🎉"

---

## Data Model

### Backend — DailyGoal

```
model DailyGoal {
  id              String   @id @default(uuid())
  userId          String
  date            DateTime @db.Date
  epTarget        Int      @default(500)
  epCurrent       Int      @default(0)
  durationTarget  Int      @default(30)    // phút
  durationCurrent Int      @default(0)     // phút
  activityTarget  Int      @default(3)
  activityCurrent Int      @default(0)
  isPerfectDay    Boolean  @default(false)
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  user User @relation(fields: [userId], references: [id])
  @@unique([userId, date])
}
```

### Backend — UserGoalSettings

```
model UserGoalSettings {
  id              String @id @default(uuid())
  userId          String @unique
  epTarget        Int    @default(500)
  durationTarget  Int    @default(30)
  activityTarget  Int    @default(3)

  user User @relation(fields: [userId], references: [id])
}
```

### API Endpoints

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/daily-goals/today` | Lấy goal progress hôm nay |
| GET | `/daily-goals/history?days=30` | Lịch sử 30 ngày (cho calendar view) |
| PUT | `/daily-goals/settings` | Cập nhật target settings |
| GET | `/daily-goals/stats` | Perfect day count, streak info |

### Flutter — Model

```dart
class DailyGoalModel extends Equatable {
  final String id;
  final DateTime date;
  final int epTarget;
  final int epCurrent;
  final int durationTarget;   // phút
  final int durationCurrent;  // phút
  final int activityTarget;
  final int activityCurrent;
  final bool isPerfectDay;

  double get epProgress => epTarget > 0
      ? epCurrent / epTarget : 0;
  double get durationProgress => durationTarget > 0
      ? durationCurrent / durationTarget : 0;
  double get activityProgress => activityTarget > 0
      ? activityCurrent / activityTarget : 0;
  bool get allCompleted =>
      epProgress >= 1 && durationProgress >= 1
      && activityProgress >= 1;
}
```

---

## Logic tích hợp

### Khi activity hoàn thành

```
createActivity()
  → Cập nhật DailyGoal:
    epCurrent += pointsEarned
    durationCurrent += durationMinutes
    activityCurrent += 1
  → Check isPerfectDay = allCompleted
  → Nếu isPerfectDay lần đầu hôm nay:
    → Gửi PERFECT_DAY notification
    → Tăng perfectDayStreak count
```

### Weekly Challenge (Phase 2)

- "5 Perfect Days trong tuần" → Bonus 1000 EP
- "Tổng 3000 EP trong tuần" → Unlock badge "Weekly Champion"

---

## Metric đo lường thành công

| Metric | Target |
|--------|--------|
| DAU (Daily Active Users) tăng | +30% sau 2 tuần |
| D7 Retention | +20% |
| Avg activities/day/user | +40% |
| Avg session time | +25% |
