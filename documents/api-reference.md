# API Reference

## Base Configuration

| Property | Value |
|----------|-------|
| **Base URL** | `http://localhost:3000` (Dev) |
| **Protocol** | HTTPS (Production) |
| **Format** | JSON |
| **Auth** | Bearer Token (JWT) |
| **Swagger** | `http://localhost:3000/api` |

---

## Xác thực

Tất cả endpoints (trừ `/auth/*`) yêu cầu header:

```http
Authorization: Bearer <access_token>
```

---

## Auth

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| POST | `/auth/social-login` | Đăng nhập Google/Apple (Firebase ID Token) | ❌ |
| GET | `/auth/me` | Lấy thông tin user hiện tại | ✅ |

---

## Users

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| PUT | `/users/me` | Cập nhật profile (displayName, avatarId) | ✅ |
| PUT | `/users/me/fcm-token` | Cập nhật FCM push token | ✅ |

---

## Houses

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| POST | `/houses` | Tạo nhà mới | ✅ |
| GET | `/houses/mine` | Lấy thông tin nhà hiện tại + thành viên | ✅ |
| POST | `/houses/join` | Tham gia nhà (invite code) | ✅ |
| POST | `/houses/leave` | Rời nhà | ✅ |
| GET | `/houses/invite` | Lấy invite code/link | ✅ |

---

## Activities

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| POST | `/activities` | Log activity hoàn thành | ✅ |
| GET | `/activities` | Lịch sử activity (phân trang) | ✅ |
| GET | `/activities/leaderboard` | Bảng xếp hạng tháng | ✅ |
| GET | `/activities/stats` | Thống kê cá nhân theo kỳ | ✅ |

### POST `/activities` — Request Body

```json
{
  "taskName": "Hút bụi",
  "durationSeconds": 1200,
  "metsValue": 3.5
}
```

### GET `/activities/leaderboard` — Query Params

| Param | Type | Default | Mô tả |
|-------|------|---------|--------|
| `scope` | `house` \| `global` | `house` | Phạm vi bảng xếp hạng |
| `month` | number | current | Tháng (1-12) |
| `year` | number | current | Năm |
| `limit` | number | 10 | Số lượng tối đa |

---

## Tasks

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| GET | `/tasks` | Lấy danh sách task của user | ✅ |
| POST | `/tasks` | Tạo custom task mới | ✅ |
| PUT | `/tasks/:id` | Cập nhật task | ✅ |
| DELETE | `/tasks/:id` | Xóa task | ✅ |

---

## Task Templates (CMS-managed)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| GET | `/task-templates` | Danh sách templates (đa ngôn ngữ) | ✅ |

---

## Rewards

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| GET | `/rewards` | Danh sách coupon trong shop | ✅ |
| POST | `/rewards` | Tạo coupon mới | ✅ |
| PUT | `/rewards/:id` | Cập nhật coupon | ✅ |
| DELETE | `/rewards/:id` | Xóa coupon | ✅ |
| POST | `/rewards/:id/redeem` | Đổi coupon (trừ EP) | ✅ |

---

## Redemptions

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| GET | `/redemptions` | Lịch sử đổi thưởng | ✅ |
| PUT | `/redemptions/:id/use` | Đánh dấu đã sử dụng | ✅ |

---

## Notifications

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| GET | `/notifications` | Danh sách thông báo (phân trang) | ✅ |
| GET | `/notifications/unread-count` | Số thông báo chưa đọc | ✅ |
| PATCH | `/notifications/:id/read` | Đánh dấu đã đọc | ✅ |
| PATCH | `/notifications/read-all` | Đánh dấu tất cả đã đọc | ✅ |
| DELETE | `/notifications/:id` | Xóa thông báo | ✅ |
| POST | `/notifications/test` | Tạo thông báo test (dev) | ✅ |

---

## Gifts

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| GET | `/gifts/catalog` | Danh sách quà tặng + balance + thành viên | ✅ |
| POST | `/gifts/send` | Gửi quà tặng (trừ EP từ sender) | ✅ |
| GET | `/gifts/history` | Lịch sử gửi/nhận quà (phân trang) | ✅ |

### GET `/gifts/catalog` — Query Params

| Param | Type | Default | Mô tả |
|-------|------|---------|--------|
| `locale` | string | `vi` | Ngôn ngữ cho tên/mô tả quà (fallback: `en`) |

### POST `/gifts/send` — Request Body

```json
{
  "giftRewardId": "uuid",
  "receiverId": "uuid",
  "message": "Cảm ơn em! (tuỳ chọn, tối đa 100 ký tự)",
  "locale": "vi"
}
```

| Field | Type | Required | Mô tả |
|-------|------|----------|--------|
| `giftRewardId` | UUID | ✅ | ID quà tặng |
| `receiverId` | UUID | ✅ | ID người nhận |
| `message` | string | ❌ | Lời nhắn (tối đa 100 ký tự) |
| `locale` | string | ❌ | Ngôn ngữ cho reward name snapshot (default: `vi`) |

### GET `/gifts/history` — Query Params

| Param | Type | Default | Mô tả |
|-------|------|---------|--------|
| `type` | `sent` \| `received` | null (tất cả) | Lọc theo chiều |
| `page` | number | 1 | Trang |
| `limit` | number | 20 | Số lượng/trang |

---

## Admin (CMS)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|--------|------|
| POST | `/admin/auth/login` | Admin đăng nhập | ❌ |
| GET | `/admin/users` | Danh sách users | Admin |
| GET | `/admin/houses` | Danh sách houses | Admin |
| GET | `/admin/stats/*` | Dashboard statistics | Admin |
| CRUD | `/admin/task-templates/*` | Quản lý task templates | Admin |

---

## Response Format

### Thành công

```json
{
  "success": true,
  "data": { ... }
}
```

### Lỗi

```json
{
  "statusCode": 400,
  "message": "Error description",
  "error": "Bad Request"
}
```

---

## Mã lỗi

| HTTP | Mô tả |
|------|--------|
| 400 | Request không hợp lệ |
| 401 | Token thiếu hoặc hết hạn |
| 403 | Không có quyền (VD: chưa join house) |
| 404 | Resource không tồn tại |
| 409 | Conflict (VD: đã join house khác) |

### Lỗi nghiệp vụ

| Code | Mô tả |
|------|--------|
| `HOUSE_FULL` | Nhà đã đạt 4 thành viên |
| `ALREADY_IN_HOUSE` | User đã thuộc nhà khác |
| `INSUFFICIENT_BALANCE` | Không đủ EP để đổi/gửi |
| `REWARD_NOT_FOUND` | Coupon không tồn tại |

---

## Phân trang

```
GET /activities?page=1&limit=20
```

```json
{
  "items": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```
