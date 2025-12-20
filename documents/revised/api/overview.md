# API Specification Overview

## Base Configuration

| Property | Value |
|----------|-------|
| **Base URL** | `https://api.ergolife.app/v1` (Production) |
| **Dev URL** | `http://localhost:3000` (Local) |
| **Protocol** | HTTPS (TLS 1.2+) |
| **Format** | JSON |
| **Authentication** | Bearer Token (JWT) |

---

## Authentication

Tất cả endpoints (trừ `/auth/*`) yêu cầu header:

```http
Authorization: Bearer <access_token>
```

### Token Flow
1. Client đăng nhập với Google/Apple → Nhận Firebase ID Token
2. Client gửi ID Token đến `POST /auth/social-login`
3. Server trả về JWT Access Token
4. Client dùng JWT cho các requests tiếp theo

### Token Lifetime
- Access Token: **7 ngày**
- Khi hết hạn: Client phải đăng nhập lại

---

## Response Format

### Success Response
```json
{
  "success": true,
  "data": {
    // Response payload
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message"
  }
}
```

---

## Error Codes

| HTTP Status | Code | Description |
|-------------|------|-------------|
| 400 | `BAD_REQUEST` | Invalid request body |
| 401 | `UNAUTHORIZED` | Missing or invalid token |
| 403 | `FORBIDDEN` | Không có quyền truy cập resource |
| 404 | `NOT_FOUND` | Resource không tồn tại |
| 409 | `CONFLICT` | Conflict (VD: đã join house khác) |
| 422 | `VALIDATION_ERROR` | Validation failed |
| 500 | `INTERNAL_ERROR` | Server error |

### Domain-Specific Errors

| Code | Description |
|------|-------------|
| `HOUSE_FULL` | House đã đạt 4 thành viên |
| `ALREADY_IN_HOUSE` | User đã thuộc house khác |
| `INSUFFICIENT_BALANCE` | Không đủ điểm để đổi thưởng |
| `REWARD_NOT_FOUND` | Coupon không tồn tại hoặc đã bị xóa |

---

## Rate Limiting

| Endpoint Type | Limit |
|---------------|-------|
| Auth endpoints | 10 requests/minute |
| Standard endpoints | 100 requests/minute |
| Activity logging | 20 requests/minute |

Response khi bị limit:
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMITED",
    "message": "Too many requests, please try again later"
  }
}
```

---

## API Endpoints Summary

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| **Auth** | | | |
| POST | `/auth/social-login` | Đăng nhập với Firebase token | ❌ |
| GET | `/auth/me` | Lấy thông tin user hiện tại | ✅ |
| | | | |
| **Users** | | | |
| PUT | `/users/me` | Cập nhật profile | ✅ |
| PUT | `/users/me/fcm-token` | Cập nhật FCM token | ✅ |
| | | | |
| **Houses** | | | |
| POST | `/houses` | Tạo house mới | ✅ |
| GET | `/houses/mine` | Lấy thông tin house hiện tại | ✅ |
| POST | `/houses/join` | Tham gia house | ✅ |
| POST | `/houses/leave` | Rời house | ✅ |
| GET | `/houses/invite` | Lấy invite code/link | ✅ |
| | | | |
| **Activities** | | | |
| POST | `/activities` | Log activity mới | ✅ |
| GET | `/activities` | Lấy history activities | ✅ |
| GET | `/activities/leaderboard` | Bảng xếp hạng tuần | ✅ |
| | | | |
| **Rewards** | | | |
| GET | `/rewards` | Danh sách rewards trong shop | ✅ |
| POST | `/rewards` | Tạo reward mới | ✅ |
| PUT | `/rewards/:id` | Cập nhật reward | ✅ |
| DELETE | `/rewards/:id` | Xóa reward | ✅ |
| POST | `/rewards/:id/redeem` | Đổi reward | ✅ |
| | | | |
| **Redemptions** | | | |
| GET | `/redemptions` | Lịch sử đổi thưởng | ✅ |
| PUT | `/redemptions/:id/use` | Đánh dấu đã sử dụng | ✅ |

---

## Pagination

Các endpoint trả về danh sách hỗ trợ pagination:

### Request
```
GET /activities?page=1&limit=20
```

### Response
```json
{
  "success": true,
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "totalPages": 8
    }
  }
}
```

---

## Swagger Documentation

Khi chạy backend local, truy cập Swagger UI tại:
```
http://localhost:3000/api
```
