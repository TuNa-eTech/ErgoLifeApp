# CMS Dashboard

## Tổng quan

Admin dashboard cho quản lý nội dung và giám sát ứng dụng ErgoLife.

---

## Tech Stack

| Component | Công nghệ |
|-----------|-----------|
| Framework | React 18 |
| Build Tool | Vite |
| UI Library | Ant Design |
| HTTP Client | Axios |
| Routing | React Router |
| Language | TypeScript |

---

## Bắt đầu nhanh

```bash
cd cms
yarn install
yarn dev          # http://localhost:5173
yarn build        # Production build
```

---

## Pages

### Login

- Admin đăng nhập riêng biệt (không dùng Firebase Auth)
- Endpoint: `POST /admin/auth/login`
- JWT token lưu trong localStorage

### Dashboard

Tổng quan số liệu:

| Widget | Dữ liệu |
|--------|---------|
| Stat Cards | Tổng users, activities, houses |
| Trend Indicators | So sánh với kỳ trước |
| Activity Chart | Biểu đồ activities theo thời gian |
| Streak Stats | Thống kê streak users |
| User Growth | Biểu đồ tăng trưởng users |
| House Distribution | Phân bố nhà |
| Leaderboard Preview | Top users |

### Users

- Danh sách tất cả users (phân trang)
- Xem chi tiết: profile, streak, EP balance, house
- Lọc/tìm kiếm

### Houses

- Danh sách tất cả nhà (phân trang)
- Xem chi tiết: thành viên, activities
- Lọc theo số thành viên, trạng thái

### Task Templates

CRUD quản lý task templates ứng dụng:

| Field | Mô tả |
|-------|--------|
| METs Value | Hệ số cường độ |
| Duration | Thời gian mặc định (phút) |
| Icon | Material icon name |
| Color | Hex color |
| Category | Phân loại |
| Sort Order | Thứ tự hiển thị |
| Status | Active / Inactive |
| EN Translation | Tên + mô tả tiếng Anh |
| VI Translation | Tên + mô tả tiếng Việt |

---

## API Integration

CMS gọi API qua prefix `/admin/*`:

| Endpoint | Mô tả |
|----------|--------|
| `POST /admin/auth/login` | Đăng nhập admin |
| `GET /admin/users` | Danh sách users |
| `GET /admin/houses` | Danh sách houses |
| `GET /admin/stats/overview` | Tổng quan statistics |
| `GET /admin/stats/activity` | Activity statistics |
| `GET /admin/stats/streaks` | Streak statistics |
| `GET /admin/task-templates` | Danh sách templates |
| `POST /admin/task-templates` | Tạo template |
| `PUT /admin/task-templates/:id` | Cập nhật template |
| `DELETE /admin/task-templates/:id` | Xóa template |

---

## Cấu trúc

```
cms/src/
├── components/          # Shared components (ErrorState, etc.)
├── pages/
│   ├── Login.tsx
│   ├── Dashboard.tsx
│   ├── Dashboard/
│   │   └── components/  # Charts, stats widgets
│   ├── Users/
│   ├── Houses/
│   ├── TaskTemplates.tsx
│   └── TaskTemplateEditor.tsx
├── services/            # API client
└── App.tsx              # Router setup
```
