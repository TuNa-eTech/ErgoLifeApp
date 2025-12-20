# API: Users

## Endpoints

---

## PUT `/users/me`

Cập nhật profile của user hiện tại.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Body:**
```json
{
  "displayName": "Minh Nguyễn",
  "avatarId": 5
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| displayName | string | ❌ | 2-30 ký tự |
| avatarId | number | ❌ | 1-20 (trong thư viện avatar) |

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "displayName": "Minh Nguyễn",
    "avatarId": 5,
    "email": "user@gmail.com",
    "walletBalance": 2500,
    "houseId": "660e8400-e29b-41d4-a716-446655441111"
  }
}
```

**Error (422):**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Display name must be between 2 and 30 characters"
  }
}
```

---

## PUT `/users/me/fcm-token`

Cập nhật Firebase Cloud Messaging token cho push notifications.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Body:**
```json
{
  "fcmToken": "dYjK8L2xQPGD:APA91bHJdK..."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| fcmToken | string | ✅ | FCM token từ firebase_messaging |

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "message": "FCM token updated successfully"
  }
}
```

---

## GET `/users/:id`

Lấy thông tin user khác (chỉ trong cùng house).

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
```

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| id | UUID | User ID |

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "displayName": "Lan Trần",
    "avatarId": 8,
    "walletBalance": 1800
  }
}
```

**Error (403):**
```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "You can only view users in your house"
  }
}
```

> **Note:** Chỉ có thể xem thông tin user nếu cùng thuộc một house.
