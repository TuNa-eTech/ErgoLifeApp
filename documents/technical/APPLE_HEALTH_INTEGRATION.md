# Apple Health (HealthKit) Integration

## 1. Tổng Quan

ErgoLife tích hợp Apple Health (HealthKit) để đọc dữ liệu sức khỏe thực từ Apple Watch/iPhone và ghi workouts ngược lại HealthKit. Tích hợp hoạt động trên iOS thông qua package `health` v13.3.1.

**Nguyên tắc:** Apple Health là tính năng **opt-in bổ sung**. Mọi user đều dùng app bình thường mà không cần kết nối. Khi không có dữ liệu HealthKit, app tự động fallback về công thức METs.

---

## 2. Dữ Liệu HealthKit

### Đang sử dụng

| Loại | HealthDataType | Mục đích |
|------|----------------|----------|
| Active Energy | `ACTIVE_ENERGY_BURNED` | Calories thực thay METs | 
| Heart Rate | `HEART_RATE` | Xác minh cường độ, HR zone bonus |
| Steps | `STEPS` | Bước chân/ngày trên Home |
| Body Weight | `WEIGHT` | Cá nhân hóa công thức calories |
| Workouts | `WORKOUT` (write) | Ghi phiên tập vào Health |

### Mở rộng (V2+)

| Loại | Giá trị |
|------|---------|
| `RESTING_HEART_RATE` | Đánh giá fitness level |
| `VO2MAX` | Fitness score cá nhân |
| `SLEEP_IN_BED` | Gợi ý dựa trên giấc ngủ |

---

## 3. Kiến Trúc

```
lib/
├── core/
│   ├── services/
│   │   └── health_service.dart           ← HealthKit abstraction layer
│   └── di/
│       └── service_locator.dart          ← DI cho HealthBloc, HealthRepository
├── data/
│   ├── repositories/
│   │   └── health_repository.dart        ← Repository pattern, Either<Failure, T>
│   └── models/
│       ├── health_data_model.dart        ← SessionHealthData, DailyHealthSummary
│       └── activity_model.dart           ← CreateActivityRequest + health fields
├── blocs/
│   ├── health/
│   │   ├── health_bloc.dart              ← Permission flow, connect/disconnect
│   │   ├── health_event.dart
│   │   └── health_state.dart
│   ├── session/
│   │   ├── session_bloc.dart             ← 10s health polling, workout write
│   │   └── session_state.dart            ← heartRateMultiplier, heartRateZone
│   └── home/
│       ├── home_bloc.dart                ← Fetch daily health summary
│       └── home_state.dart               ← DailyHealthSummary? field
└── ui/
    └── screens/
        ├── home/widgets/
        │   └── health_summary_card.dart  ← Daily Steps/Calories/HR pills
        └── tasks/widgets/
            └── compact_session_stats.dart ← HR zone badge, EP multiplier
```

### Data Flow

```
┌──────────────┐     ┌──────────────────┐     ┌────────────────┐
│ HealthService │────▶│ HealthRepository │────▶│  SessionBloc   │
│ (health pkg)  │     │  (Either<F,T>)   │     │ (10s polling)  │
└──────────────┘     └──────────────────┘     └───────┬────────┘
                            │                          │
                            │                          ▼
                            │                   ┌──────────────┐
                            │                   │ SessionState │
                            │                   │ HR, Calories │
                            │                   │ HR Zone, EP  │
                            │                   └──────┬───────┘
                            │                          │
                            ▼                          ▼
                     ┌──────────────┐          ┌──────────────┐
                     │   HomeBloc   │          │ Active Screen│
                     │ daily fetch  │          │ HR badge, EP │
                     └──────┬───────┘          └──────────────┘
                            │
                            ▼
                     ┌──────────────────┐
                     │ HealthSummaryCard│
                     │ Steps/Cal/HR    │
                     └──────────────────┘
```

---

## 4. Tính Năng Chi Tiết

### 4.1. Real-time Tracking (Active Session)

Trong phiên tập, `SessionBloc` poll dữ liệu health mỗi **10 giây**:

| Metric | Source | Fallback |
|--------|--------|----------|
| Heart Rate | HealthKit `HEART_RATE` | Không hiển thị |
| Calories | HealthKit `ACTIVE_ENERGY_BURNED` | METs × 3.5 × weight / 200 × phút |
| Body Weight | HealthKit `WEIGHT` (cached) | Mặc định 65kg |

**UI hiển thị:**
- ❤️ Nhịp tim BPM với **HR zone badge** (REST / LIGHT / FAT BURN / CARDIO)
- 🔥 Calories label đổi thành "KCAL ♥" khi dùng HealthKit data
- ⚡ EP multiplier hiển thị (1.2x EP, 1.5x EP)

### 4.2. HR Zone System (Proof of Effort)

EP bonus dựa trên nhịp tim thực, thưởng nỗ lực thật sự:

| Zone | BPM Range | EP Multiplier | Màu |
|------|-----------|---------------|-----|
| REST | < 80 | 0.8x (penalty) | Xám xanh |
| LIGHT | 80–99 | 1.0x (standard) | Xanh lá |
| FAT BURN | 100–129 | 1.2x (bonus) | Cam |
| CARDIO | 130+ | 1.5x (max bonus) | Đỏ |

**Công thức EP mới:**
```
EP = phút × METs × 10 × heartRateMultiplier
```

VD: Lau nhà (METs 3.5), 20 phút, HR zone CARDIO:
```
EP = 20 × 3.5 × 10 × 1.5 = 1,050 EP (thay vì 700 EP)
```

### 4.3. Workout Write

Khi kết thúc phiên tập, app ghi workout vào HealthKit:
- Activity type: `FUNCTIONAL_STRENGTH_TRAINING`
- Duration: thời gian thực
- Calories: real (HealthKit) hoặc estimated (METs)

### 4.4. Daily Health Dashboard (Home Screen)

`HealthSummaryCard` trên Home hiển thị 3 pills:

| Pill | Data | Icon |
|------|------|------|
| Steps | Bước chân hôm nay | 🚶 |
| Active Calories | Calories tiêu hao hôm nay | 🔥 |
| Resting HR | Nhịp tim nghỉ trung bình | ❤️ |

**Khi chưa kết nối:** Card CTA "Connect Apple Health" với nút bấm → trigger `ConnectHealth` event.

### 4.5. Health Data lên Backend

Khi `createActivity`, app gửi thêm 3 optional fields:

```json
{
  "taskName": "Hút bụi",
  "durationSeconds": 765,
  "metsValue": 3.5,
  "magicWipePercentage": 95,
  "avgHeartRate": 128,
  "realCaloriesBurned": 142,
  "healthDataSource": "healthkit"
}
```

Backend ignore unknown fields → không lỗi. Sẵn sàng để backend parse khi thêm columns sau.

---

## 5. Permission Strategy

### Đặc thù HealthKit

Apple **KHÔNG cho phép** app biết user đã từ chối hay chưa. Dialog permission chỉ hiện **1 lần duy nhất**. Đây là thiết kế bảo mật cố ý.

### Chiến lược Soft Prompt

1. **Lần đầu bấm Start session** — Bottom sheet giải thích giá trị
2. **Nếu chọn "Để sau"** — Banner nhẹ trên Home sau **7 ngày** hoặc **10 sessions**
3. **Tối đa 3 lần nhắc** — sau đó không nhắc nữa
4. **Profile Settings** — luôn có option kết nối + hướng dẫn bật trong iOS Settings

> **Lưu ý App Store:** Apple nghiêm cấm "nagging" permission. Spam request có thể bị reject.

---

## 6. Fallback & Edge Cases

| Tình huống | Xử lý |
|------------|--------|
| Không có Apple Watch | Công thức METs cũ, HR = N/A, multiplier = 1.0x |
| Có Watch nhưng không đeo | Công thức METs, không hiển thị HR zone |
| User từ chối permission | Công thức METs, option kết nối lại trong Settings |
| HealthKit trả error | Graceful fallback, log warning, tiếp tục bình thường |
| Android | Health Connect (cùng `health` package) — chưa implement |

---

## 7. Trạng Thái Triển Khai

| Phase | Scope | Status |
|-------|-------|--------|
| **1** | iOS Setup + Health Service Foundation | ✅ Done |
| **2** | Real-time HR + Calories trong Active Session | ✅ Done |
| **3** | Write Workout vào HealthKit | ✅ Done (trong Phase 2) |
| **4** | Daily Health Dashboard trên Home | ✅ Done |
| **5** | HR-based EP Bonus (Proof of Effort) | ✅ Done |

### Package

| Tiêu chí | Giá trị |
|-----------|---------|
| Package | `health` v13.3.1 |
| Downloads | 60,527 |
| Pub Points | 160/160 |
| iOS | ✅ Apple HealthKit |
| Android | ✅ Health Connect |
| License | MIT |
