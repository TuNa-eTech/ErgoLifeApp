# Nghiên Cứu Tích Hợp Health Data Đa Nền Tảng

> Samsung Watch · Huawei Watch · Xiaomi Band · Garmin Watch

## 1. Tổng Quan Kiến Trúc

ErgoLife hiện dùng package `health` v13.3.1 để đọc HealthKit trên iOS. Package này **đã hỗ trợ Health Connect trên Android**, tạo nền tảng cho việc tích hợp đa thiết bị.

```
┌──────────────────────────────────────────────────────────┐
│                    ErgoLife App (Flutter)                  │
│                                                            │
│    HealthService → HealthRepository → HealthBloc           │
│         ↕                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           health package v13.3.1                     │   │
│  │   ┌──────────────┐     ┌──────────────────────┐     │   │
│  │   │ Apple HealthKit│     │ Google Health Connect │     │   │
│  │   │   (iOS)        │     │   (Android)            │     │   │
│  │   └──────┬─────────┘     └──────────┬─────────────┘   │   │
│  └──────────┼──────────────────────────┼─────────────────┘   │
│             │                          │                      │
└─────────────┼──────────────────────────┼──────────────────────┘
              │                          │
   ┌──────────┴──────────┐    ┌──────────┴───────────────┐
   │    Apple Watch       │    │    Health Connect Hub     │
   │    iPhone Sensors    │    │                           │
   └─────────────────────┘    │  ┌─────────┐ ┌─────────┐ │
                               │  │Samsung  │ │ Garmin  │ │
                               │  │Health   │ │Connect  │ │
                               │  └─────────┘ └─────────┘ │
                               │  ┌─────────┐ ┌─────────┐ │
                               │  │Xiaomi   │ │ Google  │ │
                               │  │Mi Fit   │ │  Fit    │ │
                               │  └─────────┘ └─────────┘ │
                               └─────────────────────────────┘
```

> [!IMPORTANT]
> **Kết luận chính:** Trên Android, **Health Connect** là lớp trung gian thống nhất. Samsung, Garmin, và Xiaomi đều sync dữ liệu vào Health Connect. Package `health` đã hỗ trợ Health Connect → **phần lớn code hiện tại có thể tái sử dụng**, chỉ cần thêm Android setup.

---

## 2. Phân Tích Từng Nền Tảng

### 2.1. Samsung Watch (Galaxy Watch / Galaxy Ring)

| Tiêu chí | Giá trị |
|----------|---------|
| **OS** | Wear OS (từ Galaxy Watch 4+) |
| **Health Platform** | Samsung Health → Health Connect |
| **Dữ liệu khả dụng** | HR, Steps, Calories, Sleep, SpO2, Body Composition |
| **Tích hợp cho ErgoLife** | ✅ **Qua Health Connect** — đã được hỗ trợ bởi `health` package |

**Cách hoạt động:**
1. Samsung Health app sync dữ liệu từ Galaxy Watch → Samsung Health
2. Samsung Health sync → Health Connect (từ Samsung Health v6.22.5+)
3. ErgoLife đọc Health Connect qua package `health`

**Yêu cầu User:**
- Bật sync Samsung Health → Health Connect trong cài đặt Samsung Health
- Cấp quyền cho ErgoLife trong Health Connect

**SDK riêng (không bắt buộc):**
- Samsung Health Data SDK (Nov 2024) — cho use cases nâng cao
- Chỉ cần nếu muốn dữ liệu riêng mà Health Connect không có

---

### 2.2. Huawei Watch (GT series, Watch 3/4, Band)

| Tiêu chí | Giá trị |
|----------|---------|
| **OS** | HarmonyOS / LiteOS |
| **Health Platform** | Huawei Health Kit (HMS Core) |
| **Dữ liệu khả dụng** | HR, Steps, Calories, Sleep, SpO2, Stress |
| **Tích hợp cho ErgoLife** | ⚠️ **Riêng biệt** — cần `huawei_health` plugin |

> [!WARNING]
> Huawei **KHÔNG** sử dụng Google Health Connect do thiếu GMS. Cần tích hợp riêng qua HMS Core Health Kit.

**Cách hoạt động:**
1. Huawei Health app sync dữ liệu từ Huawei Watch
2. App đọc qua `huawei_health` Flutter plugin → HMS Health Kit API

**Yêu cầu cài đặt:**
- Đăng ký Huawei Developer Account
- Tạo app trong AppGallery Connect
- Bật Health Kit service
- Thêm `agconnect-services.json` vào project
- Chỉ hoạt động trên thiết bị có HMS Core (Huawei phones)

**Flutter Package:**
- [`huawei_health`](https://pub.dev/packages/huawei_health) — official Huawei plugin
- Compatible: Flutter 3.16+, Dart 3.x, Android 10+

**Nhận xét:**
- Thị phần Huawei đang giảm ở nhiều thị trường
- Phức tạp setup (HMS thay GMS)
- Nên xem xét tỷ lệ user Huawei trước khi đầu tư
- **Recommend: Ưu tiên thấp**, implement sau khi có demand thực

---

### 2.3. Xiaomi (Mi Band / Redmi Watch / Amazfit)

| Tiêu chí | Giá trị |
|----------|---------|
| **OS** | RTOS (Mi Band), HyperOS (Xiaomi Watch) |
| **Health Platform** | Mi Fitness / Zepp Life → Google Fit → Health Connect |
| **Dữ liệu khả dụng** | HR, Steps, Calories, Sleep |
| **Tích hợp cho ErgoLife** | ✅ **Qua Health Connect** (gián tiếp) |

**Cách hoạt động:**
1. Mi Fitness / Zepp Life sync dữ liệu từ Mi Band
2. Mi Fitness sync → Google Fit hoặc trực tiếp Health Connect
3. ErgoLife đọc Health Connect qua package `health`

**Lưu ý quan trọng:**
- Xiaomi **KHÔNG có public API** cho third-party developers
- Phụ thuộc vào user bật sync trong Mi Fitness / Zepp Life app
- Google Fit APIs đã deprecated → chuyển sang Health Connect (2025)
- Một số thiết bị Xiaomi (HyperOS) có thể gặp vấn đề permission Health Connect

**Yêu cầu User:**
- Cài Mi Fitness hoặc Zepp Life
- Bật sync → Google Fit / Health Connect trong settings
- Cấp quyền cho ErgoLife trong Health Connect

---

### 2.4. Garmin Watch (Forerunner, Venu, Fenix, Instinct)

| Tiêu chí | Giá trị |
|----------|---------|
| **OS** | Garmin OS |
| **Health Platform** | Garmin Connect → Health Connect (từ Jun 2025) |
| **Dữ liệu khả dụng** | HR, Steps, Calories, Sleep, SpO2, Stress, Floors |
| **Tích hợp cho ErgoLife** | ✅ **Qua Health Connect** (Android 14+) |

**Cách hoạt động (phương án chính — Health Connect):**
1. Garmin app sync dữ liệu từ Garmin Watch → Garmin Connect
2. Garmin Connect sync → Health Connect (từ June 2025, Android 14+)
3. ErgoLife đọc Health Connect qua package `health`

**Dữ liệu sync được qua Health Connect:**

| Category | Metrics |
|----------|---------|
| Activity | Calories, Cycling Cadence, Distance, Elevation, HR, Speed, Steps, Swimming Strokes |
| Wellness | Body Fat, Total Calories, Floors, HR, Sleep Stages, Steps, Weight |

> [!NOTE]
> Garmin → Health Connect là **one-way** (chỉ ghi, không đọc từ Health Connect). Running power, cadence, sweat loss **không** sync.

**Phương án phụ — Garmin Health API (REST):**
- API REST trả JSON, data từ Garmin Connect cloud
- **Yêu cầu đăng ký Business Developer** — phê duyệt bởi Garmin
- OAuth 2.0 authentication
- Phù hợp cho backend integration (server-side)
- Flutter package: `watch_connectivity_garmin` (Connect IQ SDK wrapper)

---

## 3. Bảng So Sánh Tổng Hợp

| Thiết bị | Phương thức | Package | Effort | Priority |
|----------|-------------|---------|--------|----------|
| **Samsung Watch** | Health Connect | `health` (sẵn có) | 🟢 Thấp | ⭐⭐⭐ Cao |
| **Xiaomi Band** | Health Connect (qua Mi Fitness) | `health` (sẵn có) | 🟢 Thấp | ⭐⭐⭐ Cao |
| **Garmin Watch** | Health Connect (Android 14+) | `health` (sẵn có) | 🟢 Thấp | ⭐⭐ Trung bình |
| **Huawei Watch** | HMS Health Kit (riêng) | `huawei_health` (mới) | 🔴 Cao | ⭐ Thấp |

---

## 4. Chiến Lược Triển Khai Đề Xuất

### Phase 1: Android Health Connect (Samsung + Xiaomi + Garmin) — Effort: Thấp

Vì package `health` đã hỗ trợ Health Connect, chỉ cần:

#### 4.1. Cấu hình Android

```xml
<!-- android/app/src/main/AndroidManifest.xml -->

<!-- Khai báo quyền Health Connect -->
<uses-permission android:name="android.permission.health.READ_HEART_RATE"/>
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED"/>
<uses-permission android:name="android.permission.health.READ_WEIGHT"/>
<uses-permission android:name="android.permission.health.WRITE_EXERCISE"/>

<!-- Intent filter cho Health Connect permissions -->
<intent-filter>
  <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE"/>
</intent-filter>

<!-- Metadata cho Health Connect -->
<meta-data
  android:name="health_permissions"
  android:resource="@xml/health_permissions"/>
```

```xml
<!-- android/app/src/main/res/xml/health_permissions.xml -->
<permissions>
  <uses-permission name="android.permission.health.READ_HEART_RATE"/>
  <uses-permission name="android.permission.health.READ_STEPS"/>
  <uses-permission name="android.permission.health.READ_ACTIVE_CALORIES_BURNED"/>
  <uses-permission name="android.permission.health.READ_WEIGHT"/>
  <uses-permission name="android.permission.health.WRITE_EXERCISE"/>
</permissions>
```

#### 4.2. Code Changes (Minimal)

**`health_service.dart`** — Cập nhật `dataSource`:

```dart
// Detect platform để biết dữ liệu đến từ đâu
String get dataSourceName {
  if (Platform.isIOS) return 'healthkit';
  if (Platform.isAndroid) return 'health_connect';
  return 'estimate';
}
```

**`health_repository.dart`** — Thay `'healthkit'` bằng dynamic source:

```dart
// Trước:
dataSource: hasReal ? 'healthkit' : 'estimate',

// Sau:
dataSource: hasReal ? _healthService.dataSourceName : 'estimate',
```

**`health_bloc.dart`** — Cập nhật labels cho Android:

```dart
// Trước (iOS only):
"Connect Apple Health"

// Sau (cross-platform):
Platform.isIOS ? "Connect Apple Health" : "Connect Health Connect"
```

**`health_summary_card.dart`** — Cập nhật CTA text:

```dart
// Cross-platform CTA
Platform.isIOS
  ? "Connect Apple Health"
  : "Connect Health Connect"
```

#### 4.3. Tương thích thiết bị

| Watch | App cần cài trên phone | Sync setting |
|-------|----------------------|--------------|
| Samsung Galaxy Watch | Samsung Health | Settings → Health Connect → Enable |
| Xiaomi Mi Band | Mi Fitness / Zepp Life | Settings → Sync → Google Fit/Health Connect |
| Garmin Watch | Garmin Connect | Settings → Health Connect → Enable (Android 14+) |

---

### Phase 2: Huawei Health Kit (Optional — Nếu có demand)

#### Yêu cầu:
1. `flutter pub add huawei_health`
2. Đăng ký HMS Developer, tạo app, bật Health Kit
3. Thêm `agconnect-services.json`
4. Tạo `HuaweiHealthService` extends abstract `HealthServiceInterface`
5. Logic phân nhánh: HMS device → Huawei plugin, GMS device → Health Connect

#### Ước lượng effort: 3–5 ngày developer

---

## 5. So Sánh với Apple Health Hiện Tại

| Feature | Apple Health (hiện tại) | Health Connect (Phase 1) |
|---------|------------------------|--------------------------|
| Real-time HR polling | ✅ 10s interval | ✅ Tương tự (phụ thuộc watch sync speed) |
| Active Calories | ✅ Real-time | ✅ Real-time |
| Steps | ✅ Daily | ✅ Daily |
| Body Weight | ✅ 90-day lookback | ✅ Tương tự |
| Write Workout | ✅ HealthKit | ✅ Health Connect Exercise |
| HR Zone Bonus | ✅ | ✅ (nếu watch có HR sensor) |
| Permission UX | System dialog 1 lần | Health Connect permission screen |

> [!NOTE]
> **Khác biệt chính:** Health Connect permission **có thể kiểm tra** (không giống HealthKit trên iOS). Android cho phép biết user đã grant hay deny → UX flow đơn giản hơn.

---

## 6. Hạn Chế & Lưu Ý

### Real-time trên Android

| Vấn đề | Chi tiết |
|--------|----------|
| **Sync delay** | Dữ liệu từ watch → phone app → Health Connect có thể chậm 1–5 phút |
| **Không có background sync API** | Health Connect không push data real-time. App phải poll. |
| **Samsung real-time** | Samsung Health Data SDK cho real-time tốt hơn, nhưng thêm dependency |

> Apple Watch gửi HR data gần như real-time qua HealthKit. Trên Android, tùy watch vendor mà có thể chậm hơn. Đây là trade-off cần chấp nhận hoặc sử dụng vendor SDK riêng.

### Garmin

- Health Connect chỉ hỗ trợ Android 14+ 
- User Garmin + Android 13 trở xuống → không có dữ liệu (fallback METs)
- Garmin Health API (REST) yêu cầu approved business developer

### Xiaomi

- Phụ thuộc user bật sync thủ công
- Không phải tất cả dữ liệu đều sync đầy đủ (vd: HR chi tiết)
- HyperOS (Xiaomi OS mới) có thể gặp quirks với Health Connect permissions

### Huawei

- Ecosystem riêng biệt (HMS vs GMS)
- Không tương thích Health Connect
- Cần maintain riêng, tăng complexity

---

## 7. Khuyến Nghị

### Implement ngay (Low effort, high impact):

1. **Thêm Android Health Connect setup** — config AndroidManifest, permissions XML
2. **Cập nhật UI labels** — cross-platform aware ("Apple Health" vs "Health Connect")
3. **Cập nhật dataSource** — `'healthkit'` / `'health_connect'` / `'estimate'`
4. **Test với Samsung Galaxy Watch** — thiết bị phổ biến nhất

### Implement sau (Khi có demand):

5. Huawei Health Kit — chỉ khi analytics cho thấy >5% users dùng Huawei
6. Garmin REST API — cho analytics/backend integration

### Không cần thiết:

7. Samsung Health Data SDK riêng — Health Connect đã đủ cho use case hiện tại
8. Xiaomi API riêng — không tồn tại public API

---

## 8. Checklist Triển Khai Phase 1

- [ ] Thêm Health Connect permissions vào `AndroidManifest.xml`
- [ ] Tạo `res/xml/health_permissions.xml`
- [ ] Thêm Health Connect permission rationale activity
- [ ] Cập nhật `HealthService` — thêm `dataSourceName` property
- [ ] Cập nhật `HealthRepository` — dynamic data source
- [ ] Cập nhật `HealthBloc` — Android permission flow
- [ ] Cập nhật `HealthSummaryCard` — cross-platform CTA text
- [ ] Cập nhật `CompactSessionStats` — cross-platform labels
- [ ] Handle Health Connect availability check (installed/not installed)
- [ ] Test trên Android device thực với Samsung Health
- [ ] Viết hướng dẫn user setup cho từng loại watch
- [ ] Thêm in-app guide "Cách kết nối đồng hồ"
