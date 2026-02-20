# 📊 Feature: Progress Visualization

## Tổng quan

Hệ thống **Progress Visualization** cung cấp biểu đồ trực quan giúp user thấy rõ tiến trình tập luyện theo thời gian. Thay vì chỉ xem con số khô khan, user có thể "cảm nhận" sự tiến bộ qua heatmap, charts, và monthly report.

## Vấn đề hiện tại

- Stats chỉ hiện text numbers (tổng EP, tổng activities, streak...)
- Không có trend — user không biết tuần này tốt hơn hay kém hơn tuần trước
- Không có calendar view — không thấy pattern "ngày nào hay tập, ngày nào lười"
- Không có breakdown theo category — user không biết phân bổ thời gian
- Profile thiếu visual appeal — không tạo emotional attachment

---

## 4 Components chính

### 1. Activity Heatmap (Bản đồ nhiệt)

Giống **GitHub contribution graph** — lưới ô vuông 7×N tuần.

**Thiết kế:**
- Mỗi ô = 1 ngày, hiển thị ngang 7 cột (Mon-Sun), 12-16 hàng (3-4 tháng)
- Cường độ màu dựa trên **tổng EP ngày đó**:

| EP | Màu |
|----|------|
| 0 | Xám nhạt (empty) |
| 1–200 | Xanh lá nhạt (#C6E48B) |
| 201–500 | Xanh lá (#7BC96F) |
| 501–1000 | Xanh lá đậm (#239A3B) |
| 1000+ | Xanh lá rất đậm (#196127) |

**Tương tác:**
- Tap vào ô → tooltip hiện chi tiết: "T6, 14/02 — 3 activities, 780 EP, 45 phút"
- Scroll ngang để xem các tháng trước
- Header hiện: "Active X of last 30 days" + longest streak

---

### 2. Weekly Progress Chart (Biểu đồ tuần)

**Bar chart** so sánh EP mỗi ngày trong tuần hiện tại vs tuần trước.

**Thiết kế:**
- 7 cặp bars (Mon-Sun): bar đậm = tuần này, bar nhạt = tuần trước
- Đường ngang target line (từ Daily Goal nếu có)
- Phía trên chart: tổng EP tuần này + % so với tuần trước ("↑ 23% vs tuần trước")
- Indicator: ngày hôm nay được highlight

**Tuỳ chọn hiển thị:**
- Toggle giữa: EP / Duration / Activities count
- Swipe trái-phải để xem tuần khác

---

### 3. Category Breakdown (Phân bổ danh mục)

**Donut chart** (biểu đồ tròn) phân bổ thời gian theo category.

**Thiết kế:**
- Donut chart ở giữa, legend ở dưới
- Mỗi category 1 màu riêng:
  - 🏋️ Fitness → Cam
  - 🧹 Cleaning → Xanh dương
  - 🧘 Wellness → Tím
  - 🍳 Cooking → Đỏ
  - 🐕 Other → Xám
- Center text: tổng thời gian hoặc tổng activities
- Tap segment → hiện danh sách tasks trong category đó

**Period selector:** Tuần / Tháng / Tất cả

---

### 4. Streak Calendar (Lịch streak)

**Calendar month view** với ✅/❌ mỗi ngày.

**Thiết kế:**
- Grid 7 cột (Mon-Sun), hiện 1 tháng
- Mỗi ngày hiện icon dựa trên trạng thái:

| Trạng thái | Icon |
|------------|------|
| Hoàn thành activity | 🔥 (lửa cam) |
| Không tập | ⚪ (trống) |
| Streak freeze used | 🧊 (đá) |
| Perfect Day (3 goals) | ⭐ (ngôi sao vàng) |
| Tương lai | — (disabled) |

- Swipe trái-phải để đổi tháng
- Footer stats: "X days active / Y total days (Z%)"
- Tap vào ngày → popup chi tiết activities hôm đó

---

## UI Layout — Stats Screen

### Screen cấu trúc

```
StatsScreen
  ├── SegmentedControl: [Tuần | Tháng | Tổng]
  ├── Summary Cards Row
  │   ├── Total EP card
  │   ├── Activities card
  │   └── Duration card
  ├── Weekly Progress Chart
  ├── Activity Heatmap (scroll horizontal)
  ├── Category Breakdown Donut
  └── Streak Calendar
```

### Navigation

- Truy cập từ: Home Screen → "View Stats" hoặc BottomNav "Stats" tab
- Hoặc từ Profile → "My Progress"

---

## Data Model

### Backend — API Endpoints

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/stats/heatmap?months=3` | Dữ liệu heatmap (EP/ngày) |
| GET | `/stats/weekly?week=current` | EP/ngày cho 1 tuần cụ thể |
| GET | `/stats/weekly-comparison` | So sánh tuần này vs tuần trước |
| GET | `/stats/categories?period=month` | Breakdown theo category |
| GET | `/stats/calendar?month=2026-02` | Streak calendar cho 1 tháng |
| GET | `/stats/summary?period=month` | Tổng hợp stats (có sẵn, mở rộng) |

### Backend — Response DTOs

```typescript
// Heatmap
interface HeatmapDataDto {
  days: Array<{
    date: string;        // "2026-02-14"
    totalEp: number;
    activityCount: number;
    totalMinutes: number;
  }>;
}

// Weekly Comparison
interface WeeklyComparisonDto {
  currentWeek: DayStats[];   // 7 items Mon-Sun
  previousWeek: DayStats[];
  changePercent: number;     // +23 or -15
}

interface DayStats {
  date: string;
  dayOfWeek: string;
  totalEp: number;
  activityCount: number;
  totalMinutes: number;
}

// Category Breakdown
interface CategoryBreakdownDto {
  period: string;
  categories: Array<{
    category: string;
    totalMinutes: number;
    activityCount: number;
    totalEp: number;
    percentage: number;
  }>;
}

// Streak Calendar
interface StreakCalendarDto {
  month: string;
  days: Array<{
    date: string;
    status: 'active' | 'inactive' | 'freeze'
             | 'perfect' | 'future';
    activityCount: number;
    totalEp: number;
  }>;
  activeDays: number;
  totalDays: number;
}
```

### Flutter — Models

```dart
class HeatmapDay extends Equatable {
  final DateTime date;
  final int totalEp;
  final int activityCount;
  final int totalMinutes;

  /// Intensity level 0-4 cho màu sắc
  int get intensity {
    if (totalEp == 0) return 0;
    if (totalEp <= 200) return 1;
    if (totalEp <= 500) return 2;
    if (totalEp <= 1000) return 3;
    return 4;
  }
}

class WeeklyComparison extends Equatable {
  final List<DayStatModel> currentWeek;
  final List<DayStatModel> previousWeek;
  final double changePercent;

  bool get isImproved => changePercent > 0;
}

class CategoryBreakdown extends Equatable {
  final String category;
  final int totalMinutes;
  final int activityCount;
  final int totalEp;
  final double percentage;
}

class StreakCalendarDay extends Equatable {
  final DateTime date;
  final String status; // active, inactive, freeze,
                       // perfect, future
  final int activityCount;
  final int totalEp;
}
```

---

## Chart Library

### Đề xuất package

**`fl_chart`** (pub.dev) — package phổ biến nhất cho Flutter charts:
- BarChart cho Weekly Progress
- PieChart cho Category Breakdown
- Đã có 5000+ likes, maintained tốt

**Custom widget** cho:
- Activity Heatmap (grid layout + colored containers)
- Streak Calendar (TableCalendar style custom)

---

## Logic tích hợp

### Backend Query tối ưu

```sql
-- Heatmap: 1 query lấy 90 ngày
SELECT
  DATE(completed_at) as date,
  SUM(points_earned) as total_ep,
  COUNT(*) as activity_count,
  SUM(duration_seconds) / 60 as total_minutes
FROM activities
WHERE user_id = $1
  AND completed_at >= NOW() - INTERVAL '90 days'
GROUP BY DATE(completed_at)
ORDER BY date;
```

### Caching Strategy

- Heatmap: cache 1 giờ (stale-while-revalidate)
- Weekly chart: invalidate sau mỗi activity mới
- Category breakdown: cache 30 phút
- Calendar: invalidate daily

---

## Monthly Report Card (Phase 2)

### Auto-generated mỗi đầu tháng

```
📊 Monthly Report — Tháng 1/2026

🔥 Streak: 28 ngày (Kỷ lục!)
⭐ EP: 12,450 (↑ 15% vs tháng trước)
💪 Activities: 45 lần
⏱️ Thời gian: 18h 30m
🏆 Rank: #2 trong House

📈 Best Day: 14/01 — 1,200 EP
🏃 Top Task: Rửa bát (15 lần)
❤️ Avg HR: 95 bpm (LIGHT zone)

Tháng sau hãy đặt mục tiêu cao hơn! 🚀
```

- Gửi dưới dạng in-app notification + rich push
- Option share report card dạng ảnh đẹp

---

## Metric đo lường thành công

| Metric | Target |
|--------|--------|
| Stats screen views/week | 3+ lần/user |
| D30 Retention | +20% |
| Screenshot/Share rate | +35% |
| Feature adoption rate | 60%+ users xem stats |
