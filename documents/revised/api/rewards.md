# API: Rewards & Redemptions

## Rewards Endpoints

---

## GET `/rewards`

Danh sách rewards trong shop của house.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
```

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| activeOnly | boolean | true | Chỉ lấy rewards đang active |

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "rewards": [
      {
        "id": "880e8400-e29b-41d4-a716-446655443333",
        "title": "Miễn rửa bát 1 ngày",
        "cost": 1000,
        "icon": "dish_free",
        "description": "Được miễn rửa bát trong 1 ngày",
        "creator": {
          "id": "550e8400-e29b-41d4-a716-446655440001",
          "displayName": "Lan Trần"
        },
        "isActive": true,
        "createdAt": "2025-12-15T08:00:00.000Z"
      },
      {
        "id": "880e8400-e29b-41d4-a716-446655443334",
        "title": "Massage chân 15 phút",
        "cost": 1500,
        "icon": "massage",
        "description": null,
        "creator": {
          "id": "550e8400-e29b-41d4-a716-446655440000",
          "displayName": "Minh Nguyễn"
        },
        "isActive": true,
        "createdAt": "2025-12-10T10:00:00.000Z"
      }
    ],
    "userBalance": 3270
  }
}
```

---

## POST `/rewards`

Tạo reward mới.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Body:**
```json
{
  "title": "Bữa sáng trên giường",
  "cost": 2000,
  "icon": "breakfast",
  "description": "Được phục vụ bữa sáng tại giường vào cuối tuần"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| title | string | ✅ | 2-50 ký tự |
| cost | number | ✅ | 100-10000 |
| icon | string | ✅ | 1-30 ký tự |
| description | string | ❌ | max 200 ký tự |

### Response

**Success (201):**
```json
{
  "success": true,
  "data": {
    "id": "880e8400-e29b-41d4-a716-446655443335",
    "title": "Bữa sáng trên giường",
    "cost": 2000,
    "icon": "breakfast",
    "description": "Được phục vụ bữa sáng tại giường vào cuối tuần",
    "isActive": true,
    "createdAt": "2025-12-20T11:00:00.000Z"
  }
}
```

---

## PUT `/rewards/:id`

Cập nhật reward (chỉ creator hoặc owner house).

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Body:**
```json
{
  "title": "Bữa sáng trên giường (cuối tuần)",
  "cost": 2500
}
```

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "id": "880e8400-e29b-41d4-a716-446655443335",
    "title": "Bữa sáng trên giường (cuối tuần)",
    "cost": 2500,
    "icon": "breakfast",
    "isActive": true,
    "updatedAt": "2025-12-20T12:00:00.000Z"
  }
}
```

---

## DELETE `/rewards/:id`

Xóa reward (soft delete - set `isActive = false`).

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "message": "Reward deleted successfully"
  }
}
```

---

## POST `/rewards/:id/redeem`

Đổi reward bằng điểm.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
```

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "redemption": {
      "id": "990e8400-e29b-41d4-a716-446655444444",
      "rewardTitle": "Miễn rửa bát 1 ngày",
      "pointsSpent": 1000,
      "status": "PENDING",
      "redeemedAt": "2025-12-20T14:00:00.000Z"
    },
    "wallet": {
      "previousBalance": 3270,
      "pointsSpent": 1000,
      "newBalance": 2270
    }
  }
}
```

**Error (422):**
```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_BALANCE",
    "message": "You need 730 more points to redeem this reward"
  }
}
```

### Side Effects
- Push notification gửi đến tất cả members khác trong house
- Notification content: `"[User] vừa đổi coupon: [Reward Title]!"`

---

## Redemptions Endpoints

---

## GET `/redemptions`

Lịch sử đổi thưởng.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
```

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| status | string | all | `PENDING`, `USED`, or `all` |
| page | number | 1 | Trang |
| limit | number | 20 | Items/trang |

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "990e8400-e29b-41d4-a716-446655444444",
        "rewardTitle": "Miễn rửa bát 1 ngày",
        "pointsSpent": 1000,
        "status": "PENDING",
        "redeemedAt": "2025-12-20T14:00:00.000Z",
        "usedAt": null
      },
      {
        "id": "990e8400-e29b-41d4-a716-446655444445",
        "rewardTitle": "Chọn phim tối nay",
        "pointsSpent": 500,
        "status": "USED",
        "redeemedAt": "2025-12-18T20:00:00.000Z",
        "usedAt": "2025-12-18T21:30:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 5,
      "totalPages": 1
    }
  }
}
```

---

## PUT `/redemptions/:id/use`

Đánh dấu redemption đã được sử dụng.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
```

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "id": "990e8400-e29b-41d4-a716-446655444444",
    "status": "USED",
    "usedAt": "2025-12-20T18:00:00.000Z"
  }
}
```

**Error (400):**
```json
{
  "success": false,
  "error": {
    "code": "BAD_REQUEST",
    "message": "This redemption has already been used"
  }
}
```

> **Note:** Bất kỳ member nào trong house cũng có thể đánh dấu redemption là "used".
