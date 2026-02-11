# ErgoLife — The Home Athlete

> Biến việc nhà thành cơ hội rèn luyện sức khỏe.

ErgoLife giúp các hộ gia đình/cặp đôi phân chia công việc nhà công bằng dựa trên nỗ lực thể chất, hướng dẫn an toàn công thái học, và tạo niềm vui thông qua Gamification.

---

## Tổng quan hệ thống

| Component | Công nghệ | Thư mục |
|-----------|-----------|---------|
| Mobile App | Flutter / Dart | `app/` |
| Backend API | NestJS / TypeScript | `backend/` |
| Database | PostgreSQL + Prisma ORM | `backend/prisma/` |
| CMS Dashboard | React + Vite + Ant Design | `cms/` |
| Landing Page | HTML / CSS / JS | `landing-page/` |
| Docs | Markdown | `documents/` |

---

## Bắt đầu nhanh

### Yêu cầu

- **Node.js** >= 18
- **Yarn** >= 1.22
- **Flutter** >= 3.35 (quản lý qua FVM)
- **PostgreSQL** >= 14
- **Docker** (tuỳ chọn — dùng cho DB)

### 1. Backend

```bash
cd backend
cp .env.example .env        # Cấu hình DATABASE_URL, JWT_SECRET, Firebase, v.v.
yarn install
yarn prisma generate         # Tạo Prisma Client
yarn prisma migrate dev      # Chạy migration
yarn prisma db seed          # Seed task templates + gift rewards
yarn start:dev               # Khởi động ở http://localhost:3000
```

Swagger UI: [http://localhost:3000/api](http://localhost:3000/api)

### 2. Mobile App

```bash
cd app
fvm flutter pub get
fvm flutter run              # Chạy trên thiết bị/emulator
```

### 3. CMS Dashboard

```bash
cd cms
yarn install
yarn dev                     # Khởi động ở http://localhost:5173
```

---

## Cấu trúc thư mục

```
ErgoLifeApp/
├── app/                     # Flutter mobile app
│   ├── lib/
│   │   ├── blocs/           # Business logic (BLoC pattern)
│   │   ├── core/            # Config, DI, navigation, constants
│   │   ├── data/            # Models, repositories, API client
│   │   └── ui/              # Screens, widgets, themes
│   └── ios/ android/        # Platform-specific code
├── backend/                 # NestJS REST API
│   ├── prisma/              # Schema, migrations, seeds
│   └── src/modules/         # Feature modules
├── cms/                     # React admin dashboard
│   └── src/pages/           # Dashboard, Users, Houses, TaskTemplates
├── documents/               # Tài liệu dự án
└── landing-page/            # Website giới thiệu
```

---

## Tài liệu chi tiết

| Tài liệu | Mô tả |
|-----------|--------|
| [Kiến trúc hệ thống](architecture.md) | Tech stack, luồng dữ liệu, mô hình triển khai |
| [Tính năng](features.md) | Mô tả tất cả chức năng ứng dụng |
| [API Reference](api-reference.md) | Tất cả endpoints, request/response format |
| [Database Schema](database-schema.md) | Mô hình dữ liệu Prisma/PostgreSQL |
| [Mobile App](mobile-app.md) | Kiến trúc Flutter, navigation, state management |
| [CMS Dashboard](cms.md) | Admin dashboard cho quản lý nội dung |

---

## Đối tượng người dùng

- Các cặp đôi sống chung, bạn cùng phòng, hộ gia đình nhỏ
- Độ tuổi: 22–35 (Gen Z, Millennials)
- Yêu công nghệ, quan tâm sức khỏe, thích sự công bằng

## Triết lý thiết kế

- **Clean Kinetic Minimalism** — Tối giản & Năng động
- Hỗ trợ **Dark Mode + Light Mode**
- Font: **Inter** / SF Pro
- Accent: Electric Blue `#0D59F2` + Vibrant Orange `#FF6B00`
