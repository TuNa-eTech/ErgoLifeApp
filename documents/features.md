# Tính năng ứng dụng ErgoLife

## 1. 🔐 Xác thực & Onboarding

### Đăng nhập
- **Google Sign-in** và **Apple Sign-in** qua Firebase Auth
- Không hỗ trợ email/password (giảm ma sát)
- JWT access token cho mọi API request

### Onboarding
- **Welcome Screen** — Giới thiệu ứng dụng với animation
- **Setup Profile** — Nhập tên hiển thị, chọn avatar 3D
- **Tạo/Join House** — Tạo nhà mới hoặc tham gia nhà qua invite code

---

## 2. 🏠 Quản lý nhà (Household)

- Tạo nhà mới → hệ thống tạo `inviteCode` tự động
- Mời thành viên qua **QR Code** hoặc **Deep Link**
- Tối đa **4 thành viên** / nhà
- 1 user thuộc 1 nhà tại một thời điểm
- Rời nhà bất cứ lúc nào
- Nhà cá nhân (`isPersonal`) cho user chưa muốn tạo nhóm

---

## 3. 🏋️ Vòng lặp chính (Core Loop)

### 3.1. Chọn task
- Hiển thị task dạng **grid 2 cột**
- Task từ **templates CMS-managed** (đa ngôn ngữ EN/VI)
- User có thể **tạo custom task** riêng
- Mỗi task hiển thị: icon, tên, METs, thời gian, EP ước tính

### 3.2. Ergo-Coach (Hướng dẫn)
- Modal popup hiển thị **Lottie animation** tư thế đúng
- Micro-copy hướng dẫn an toàn công thái học
- Nút "Sẵn sàng" → bắt đầu timer

### 3.3. Active Session (Đếm giờ)
- **Timer đếm tiến** (00:00 → ...)
- Hiển thị: thời gian, calo, EP tích lũy, **nhịp tim** (nếu có Apple Health)
- **Real-time HealthKit polling** — HR + calories thực mỗi 10s
- **HR zone badge** — REST / LIGHT / FAT BURN / CARDIO (đổi màu theo zone)
- **Wakelock** — giữ màn hình sáng
- Nút Pause / Finish dễ bấm
- **iOS Live Activity** — hiển thị trên Dynamic Island
- **Ghi Workout vào HealthKit** khi kết thúc session

### 3.4. Magic Wipe (Xác nhận)
- Lớp phủ bụi che toàn màn hình
- User **vuốt ngón tay** để xoá (như vé cào)
- **Haptic feedback** rung theo nhịp vuốt
- Xoá > 70% → hiệu ứng **Confetti** chiến thắng

### 3.5. Tính điểm EP

```
EP = (Thời gian phút) × METs × 10 × HR Multiplier
```

| HR Zone | BPM | Multiplier |
|---------|-----|------------|
| REST | < 80 | 0.8x (penalty) |
| LIGHT | 80–99 | 1.0x |
| FAT BURN | 100–129 | 1.2x |
| CARDIO | 130+ | 1.5x |

VD: Rửa bát (METs 2.5), 20 phút, FAT BURN zone = 20 × 2.5 × 10 × 1.2 = **600 EP**

> **Không có Apple Health:** HR Multiplier = 1.0x (tính EP cũ)

---

## 4. 🔥 Hệ thống Streak

- Streak tăng mỗi ngày user hoàn thành ít nhất 1 activity
- **Streak Milestone** notifications (3, 7, 14, 30 ngày...)
- **Streak Freeze** (tối đa 2 lần) — bảo vệ streak khi quên
- **Streak Lost** notification khi mất streak
- **Preferred Reminder Time** — học từ patterns hoạt động của user

---

## 5. 🏆 Bảng xếp hạng (Leaderboard)

- Xếp hạng theo **tháng** (chọn month/year)
- Phạm vi: **House** hoặc **Global**
- Hiển thị tối đa **10 users** (top 3 có badge đặc biệt)
- **Leaderboard Change** notification khi thứ hạng thay đổi

---

## 6. 🎁 Rewards Shop (Đổi thưởng)

### Coupon (User-created)
- User tự tạo coupon: tên, giá EP, icon, mô tả
- User khác trong nhà đổi coupon → **trừ EP**
- Trạng thái: PENDING → USED → EXPIRED
- Notifications: NEW_REWARD, ENOUGH_POINTS, REDEMPTION_APPROVED

---

## 7. 💝 Family Gifting (Gửi quà)

### Gift Catalog (App-managed)
- 20 quà tặng tượng trưng được seed sẵn
- 4 categories: Praise, Privilege, Experience, Motivation
- **Đa ngôn ngữ EN/VI** — tên quà hiển thị theo locale app (fallback EN)
- Chi phí EP giảm từ sender balance
- Optimistic UI update sau khi gửi (không flash loading skeleton)

### Gửi quà
- Chọn quà → chọn thành viên nhà (có **avatar**) → gửi lời nhắn (tuỳ chọn)
- **Member picker** hiển thị avatar 3D của từng thành viên
- **Send button** có loading indicator, chống double-tap
- EP bị trừ từ sender (balance check atomic trong Prisma transaction)
- **GIFT_RECEIVED** push notification cho receiver
- Reward name snapshot lưu theo **locale của sender**

### Lịch sử
- Tab All / Sent / Received
- Hiển thị: quà, người gửi → người nhận, lời nhắn, EP, thời gian
- **Infinite scroll** pagination (20 items/page)

---

## 8. 🔔 Notifications

### In-app
- Notification Center với danh sách phân trang
- Badge số thông báo chưa đọc
- Đánh dấu đã đọc (từng cái / tất cả)
- Xoá thông báo

### Push (Firebase Cloud Messaging)
- **Activity Completed** — khi thành viên nhà hoàn thành task
- **Streak** — reminder, lost, milestone
- **House** — invite, member joined, leaderboard change
- **Rewards** — new reward, enough points, redemption
- **Gifts** — gift received

### Loại thông báo (15 types)

| Type | Trigger |
|------|---------|
| `ACTIVITY_COMPLETED` | Thành viên hoàn thành task |
| `STREAK_REMINDER` | Nhắc nhở duy trì streak |
| `STREAK_LOST` | Mất streak |
| `STREAK_MILESTONE` | Đạt mốc streak (3, 7, 14...) |
| `HOUSE_INVITE` | Được mời vào nhà |
| `MEMBER_JOINED` | Thành viên mới tham gia |
| `HOUSE_ACTIVITY` | Hoạt động trong nhà |
| `LEADERBOARD_CHANGE` | Thay đổi thứ hạng |
| `NEW_REWARD` | Coupon mới trong shop |
| `ENOUGH_POINTS` | Đủ EP để đổi coupon |
| `REDEMPTION_APPROVED` | Đổi thưởng thành công |
| `REDEMPTION_REJECTED` | Đổi thưởng bị từ chối |
| `GIFT_RECEIVED` | Nhận quà từ thành viên |
| `WELCOME` | Chào mừng user mới |
| `APP_UPDATE` | Thông báo cập nhật app |

---

## 9. 👤 Profile

- Xem/chỉnh sửa: tên hiển thị, avatar
- Thống kê cá nhân: streak, EP tổng, activities
- Xem thông tin nhà hiện tại
- Legal: Terms of Service, Privacy Policy

---

## 10. ❤️ Apple Health Integration

### Kết nối
- **Opt-in** — không bắt buộc, soft prompt khi bắt đầu session
- Sử dụng package `health` v13.3.1 (HealthKit trên iOS)
- Chiến lược **tối đa 3 lần nhắc**, sau đó không nhắc nữa

### Real-time Session
- Đọc **Heart Rate** + **Active Calories** từ Apple Watch mỗi 10s
- HR zone badge đổi màu: xám (REST) → xanh (LIGHT) → cam (FAT BURN) → đỏ (CARDIO)
- EP multiplier hiển thị trực tiếp (1.2x EP, 1.5x EP)
- Calories label "KCAL ♥" khi dùng HealthKit data

### Daily Health Dashboard (Home)
- Card hiển thị **Steps / Active Calories / Resting HR** hôm nay
- CTA "Connect Apple Health" khi chưa kết nối
- Tự ẩn khi không có data

### Workout Write
- Tự ghi workout vào Apple Health khi hoàn thành session
- Activity type: Functional Strength Training

### Fallback
- Không có Apple Watch → công thức METs cũ, HR = N/A
- User từ chối → dùng app bình thường, option kết nối lại trong Settings

---

## 11. 📊 CMS Dashboard (Admin)

- **Dashboard** — Tổng quan users, activities, streaks, houses
- **Users** — Quản lý danh sách user
- **Houses** — Quản lý households
- **Task Templates** — CRUD templates đa ngôn ngữ (EN/VI)
- Admin auth riêng biệt
