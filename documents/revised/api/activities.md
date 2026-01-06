# API: Activities

## Endpoints

---

## POST `/activities`

Log một activity mới (sau khi hoàn thành Magic Wipe).

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Body:**
```json
{
  "taskName": "Hút bụi",
  "durationSeconds": 1200,
  "metsValue": 3.5,
  "magicWipePercentage": 95
}
```

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| taskName | string | ✅ | 1-50 chars | Tên công việc |
| durationSeconds | number | ✅ | 60-7200 | Thời gian (giây) |
| metsValue | number | ✅ | 1.0-10.0 | Hệ số METs |
| magicWipePercentage | number | ✅ | 70-100 | % diện tích đã lau |

### Response

**Success (201):**
```json
{
  "success": true,
  "data": {
    "activity": {
      "id": "770e8400-e29b-41d4-a716-446655442222",
      "taskName": "Hút bụi",
      "durationSeconds": 1200,
      "metsValue": 3.5,
      "pointsEarned": 770,
      "bonusMultiplier": 1.1,
      "completedAt": "2025-12-20T10:30:00.000Z"
    },
    "wallet": {
      "previousBalance": 2500,
      "pointsEarned": 770,
      "newBalance": 3270
    }
  }
}
```

### Points Calculation

```
basePoints = (durationSeconds / 60) × metsValue × 10
bonus = magicWipePercentage >= 95 ? 1.1 : 1.0
pointsEarned = floor(basePoints × bonus)
```

**Example:**
- Duration: 1200s = 20 min
- METs: 3.5
- Magic Wipe: 95% → bonus 1.1
- Points: 20 × 3.5 × 10 × 1.1 = **770**

---

## GET `/activities`

Lấy lịch sử activities của user.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
```

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| page | number | 1 | Trang hiện tại |
| limit | number | 20 | Số items/trang (max 50) |
| startDate | ISO8601 | - | Lọc từ ngày |
| endDate | ISO8601 | - | Lọc đến ngày |

**Example:**
```
GET /activities?page=1&limit=10&startDate=2025-12-01
```

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "770e8400-e29b-41d4-a716-446655442222",
        "taskName": "Hút bụi",
        "durationSeconds": 1200,
        "pointsEarned": 770,
        "completedAt": "2025-12-20T10:30:00.000Z"
      },
      {
        "id": "770e8400-e29b-41d4-a716-446655442223",
        "taskName": "Rửa bát",
        "durationSeconds": 900,
        "pointsEarned": 375,
        "completedAt": "2025-12-19T20:15:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 42,
      "totalPages": 5
    },
    "summary": {
      "totalPoints": 1145,
      "totalDuration": 2100,
      "activityCount": 2
    }
  }
}
```

---

## GET `/activities/leaderboard`

Bảng xếp hạng tuần - hỗ trợ 2 scope: House (trong gia đình) và Global (toàn app).

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
```

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| scope | string | `house` | Phạm vi: `house` (trong gia đình) hoặc `global` (toàn app) |
| week | string | `current` | Tuần (format: `YYYY-Www`, VD: `2025-W51`) |

**Examples:**
```
GET /activities/leaderboard?scope=house&week=current
GET /activities/leaderboard?scope=global&week=2025-W51
```

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "scope": "house",
    "week": "2025-W51",
    "weekStart": "2025-12-16T00:00:00.000Z",
    "weekEnd": "2025-12-22T23:59:59.999Z",
    "houseName": "Nhà Nguyễn",
    "rankings": [
      {
        "rank": 1,
        "user": {
          "id": "550e8400-e29b-41d4-a716-446655440000",
          "displayName": "Minh Nguyễn",
          "avatarId": 3,
          "avatarUrl": "https://storage.ergolife.app/avatars/3.png"
        },
        "weeklyPoints": 5200,
        "activityCount": 12
      },
      {
        "rank": 2,
        "user": {
          "id": "550e8400-e29b-41d4-a716-446655440001",
          "displayName": "Lan Trần",
          "avatarId": 8,
          "avatarUrl": null
        },
        "weeklyPoints": 4800,
        "activityCount": 10
      }
    ],
    "myRanking": {
      "rank": 4,
      "weeklyPoints": 2100,
      "activityCount": 5
    },
    "totalParticipants": 6
  }
}
```

### Response Fields

| Field | Type | Scope | Description |
|-------|------|-------|-------------|
| `scope` | string | Both | `house` hoặc `global` |
| `week` | string | Both | Tuần (format: `YYYY-Www`) |
| `weekStart` | ISO8601 | Both | Thời gian bắt đầu tuần |
| `weekEnd` | ISO8601 | Both | Thời gian kết thúc tuần |
| `houseName` | string | House only | Tên nhà (chỉ có với scope=house) |
| `rankings` | array | Both | Danh sách top users |
| `myRanking` | object | Both | Vị trí của current user |
| `totalParticipants` | number | Both | Tổng số users trong scope |

### Scope Comparison

| Aspect | `scope=house` | `scope=global` |
|--------|---------------|----------------|
| Data Source | Members trong House | Tất cả users có activity |
| `houseName` | ✅ Có | ❌ `null` |
| Performance | Nhanh (ít data) | Có thể cần cache |

---

## GET `/activities/stats`

Thống kê activities của user.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
```

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| period | string | week | `week`, `month`, `all` |

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "period": "week",
    "totalPoints": 5200,
    "totalActivities": 12,
    "totalDuration": 28800,
    "estimatedCalories": 850,
    "topTasks": [
      { "taskName": "Hút bụi", "count": 4, "totalPoints": 2800 },
      { "taskName": "Rửa bát", "count": 5, "totalPoints": 1500 },
      { "taskName": "Lau nhà", "count": 3, "totalPoints": 900 }
    ],
    "streak": {
      "current": 5,
      "longest": 12
    }
  }
}
```
