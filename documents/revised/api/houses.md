# API: Houses

## Endpoints

---

## POST `/houses`

Tạo house mới.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Nhà của Mèo & Cún"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| name | string | ✅ | 2-50 ký tự |

### Response

**Success (201):**
```json
{
  "success": true,
  "data": {
    "id": "660e8400-e29b-41d4-a716-446655441111",
    "name": "Nhà của Mèo & Cún",
    "inviteCode": "clxyz123abc",
    "createdBy": "550e8400-e29b-41d4-a716-446655440000",
    "members": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "displayName": "Minh Nguyễn",
        "avatarId": 3
      }
    ],
    "createdAt": "2025-12-20T09:00:00.000Z"
  }
}
```

**Error (409):**
```json
{
  "success": false,
  "error": {
    "code": "ALREADY_IN_HOUSE",
    "message": "You are already a member of another house"
  }
}
```

---

## GET `/houses/mine`

Lấy thông tin house hiện tại của user.

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
    "id": "660e8400-e29b-41d4-a716-446655441111",
    "name": "Nhà của Mèo & Cún",
    "inviteCode": "clxyz123abc",
    "createdBy": "550e8400-e29b-41d4-a716-446655440000",
    "members": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "displayName": "Minh Nguyễn",
        "avatarId": 3,
        "walletBalance": 2500
      },
      {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "displayName": "Lan Trần",
        "avatarId": 8,
        "walletBalance": 1800
      }
    ],
    "memberCount": 2,
    "createdAt": "2025-12-20T09:00:00.000Z"
  }
}
```

**Error (404):**
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "You are not a member of any house"
  }
}
```

---

## GET `/houses/invite`

Lấy invite code và deep link.

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
    "inviteCode": "clxyz123abc",
    "deepLink": "https://ergolife.app/join/clxyz123abc",
    "qrCodeUrl": "https://api.ergolife.app/qr/clxyz123abc.png"
  }
}
```

---

## POST `/houses/join`

Tham gia house bằng invite code.

### Request

**Headers:**
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Body:**
```json
{
  "inviteCode": "clxyz123abc"
}
```

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "id": "660e8400-e29b-41d4-a716-446655441111",
    "name": "Nhà của Mèo & Cún",
    "memberCount": 2,
    "members": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "displayName": "Minh Nguyễn",
        "avatarId": 3
      },
      {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "displayName": "Lan Trần",
        "avatarId": 8
      }
    ]
  }
}
```

**Error Cases:**

| Code | Message |
|------|---------|
| `ALREADY_IN_HOUSE` | You are already a member of another house |
| `HOUSE_FULL` | This house has reached the maximum of 4 members |
| `INVALID_INVITE` | Invite code is invalid or expired |

---

## POST `/houses/leave`

Rời khỏi house hiện tại.

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
    "message": "Successfully left the house",
    "houseDeleted": false
  }
}
```

> **Note:** Nếu là thành viên cuối cùng, `houseDeleted = true` và house bị xóa hoàn toàn.

### Side Effects
- `wallet_balance` reset về 0
- User's `house_id` set về NULL
- Nếu là thành viên cuối cùng: House và tất cả rewards bị xóa

---

## GET `/houses/:code/preview`

Xem trước thông tin house trước khi join (public endpoint).

### Request

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| code | string | Invite code |

### Response

**Success (200):**
```json
{
  "success": true,
  "data": {
    "name": "Nhà của Mèo & Cún",
    "memberCount": 2,
    "isFull": false,
    "memberAvatars": [3, 8]
  }
}
```

**Error (404):**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_INVITE",
    "message": "Invite code is invalid or expired"
  }
}
```
