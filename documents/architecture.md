# Kiến trúc hệ thống

## Tech Stack

```
┌─────────────────────────────────────────────────────────────┐
│                     Mobile App (Flutter)                     │
│  BLoC Pattern · GoRouter · Dartz (Either) · GetIt (DI)      │
└──────────────────────────┬──────────────────────────────────┘
                           │ REST API (JWT)
┌──────────────────────────▼──────────────────────────────────┐
│                   Backend (NestJS)                           │
│  Modules · Guards · Pipes · Swagger · Firebase Admin SDK     │
└──────────────────────────┬──────────────────────────────────┘
                           │ Prisma ORM
┌──────────────────────────▼──────────────────────────────────┐
│                 PostgreSQL Database                          │
│  11 Models · 5 Enums · Indexed queries                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              CMS Dashboard (React + Vite)                    │
│  Ant Design · Axios · React Router                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Backend — NestJS

### Modules

| Module | Mô tả | Endpoints |
|--------|--------|-----------|
| `auth` | Đăng nhập Google/Apple qua Firebase | `/auth/*` |
| `user` | Quản lý profile, FCM token | `/users/*` |
| `houses` | Tạo/join/leave nhà, mời thành viên | `/houses/*` |
| `activities` | Log activity, lịch sử, leaderboard, stats | `/activities/*` |
| `tasks` | CRUD task cá nhân (custom + từ template) | `/tasks/*` |
| `task-templates` | Templates task CMS-managed | `/task-templates/*` |
| `rewards` | CRUD coupon đổi thưởng | `/rewards/*` |
| `redemptions` | Lịch sử đổi thưởng | `/redemptions/*` |
| `notifications` | Push notification + in-app | `/notifications/*` |
| `gifts` | Gửi quà tượng trưng trong gia đình | `/gifts/*` |
| `admin` | CMS API (auth, users, houses, stats, templates) | `/admin/*` |

### Xác thực

1. Client đăng nhập Google/Apple → nhận Firebase ID Token
2. Gửi ID Token đến `POST /auth/social-login`
3. Server xác thực với Firebase Admin SDK → trả JWT Access Token
4. Client dùng JWT `Bearer` token cho mọi request tiếp theo

### Patterns

- **Guards**: `JwtAuthGuard`, `AdminAuthGuard`
- **Decorators**: `@CurrentUser()` — inject user từ JWT
- **DTOs**: Class-validator + Swagger annotations
- **Error handling**: NestJS exception filters

---

## Mobile App — Flutter

### Kiến trúc Clean Architecture

```
lib/
├── blocs/               # Business Logic Components
│   ├── auth/            # AuthBloc
│   ├── home/            # HomeBloc (dashboard data)
│   ├── tasks/           # TasksBloc (CRUD tasks)
│   ├── gifts/           # GiftsBloc (catalog, send, history)
│   └── notification/    # NotificationBloc
├── core/
│   ├── config/          # Theme, environment config
│   ├── constants/       # API endpoints, app constants
│   ├── di/              # GetIt service locator (DI)
│   └── navigation/      # GoRouter configuration
├── data/
│   ├── models/          # Data models (fromJson/toJson)
│   ├── repositories/    # Repository pattern (API calls)
│   └── services/        # ApiClient, AuthService
└── ui/
    ├── screens/         # 17 screen folders
    └── widgets/         # Shared reusable widgets
```

### State Management: BLoC

- Mỗi feature có riêng `Event`, `State`, `Bloc`
- Dùng `dartz` `Either<Failure, Success>` cho error handling
- `BlocProvider` inject qua `GoRouter` hoặc global
- `BlocConsumer` / `BlocBuilder` cho UI rendering

### Navigation: GoRouter

- `StatefulShellRoute` cho bottom navigation (Home, Tasks, Rank, Profile)
- Deep linking support
- Route guards cho auth state

### Screens (17)

| Screen | Route | Mô tả |
|--------|-------|--------|
| Splash | `/splash` | Khởi động app |
| Welcome | `/welcome` | Giới thiệu app |
| Onboarding | `/onboarding` | Setup profile, avatar, house |
| Login | `/login` | Google/Apple sign-in |
| Home | `/` | Dashboard chính (stats, tasks, arena) |
| Tasks | `/tasks` | Danh sách task dạng grid |
| Active Session | `/active-session` | Timer đếm giờ + Live Activity |
| Leaderboard | `/leaderboard` | Bảng xếp hạng tháng |
| Profile | `/profile` | Thông tin cá nhân |
| Edit Profile | `/profile/edit` | Chỉnh sửa profile |
| House Detail | `/house/detail` | Chi tiết nhà |
| Create House | `/house/create` | Tạo nhà mới |
| Invite Members | `/house/invite` | Mời thành viên (QR/link) |
| Notifications | `/notifications` | Trung tâm thông báo |
| Gifts | `/gifts` | Cửa hàng quà tặng |
| Gift History | `/gifts/history` | Lịch sử gửi/nhận quà |
| Rewards | (tab) | Cửa hàng đổi thưởng |

---

## CMS Dashboard — React

### Tech Stack

- **React** + **Vite** (build tool)
- **Ant Design** (UI library)
- **Axios** (HTTP client)
- **React Router** (navigation)

### Pages

| Page | Mô tả |
|------|--------|
| Login | Admin đăng nhập |
| Dashboard | Tổng quan stats (users, activities, streaks, houses) |
| Users | Quản lý danh sách user |
| Houses | Quản lý danh sách nhà |
| Task Templates | CRUD task templates (đa ngôn ngữ EN/VI) |

---

## Database — PostgreSQL

- **ORM**: Prisma 6.x
- **11 Models**: User, House, Activity, Reward, Redemption, Notification, TaskTemplate, TaskTemplateTranslation, CustomTask, GiftReward, GiftRewardTranslation, GiftTransaction
- **5 Enums**: AuthProvider, RedemptionStatus, GiftRewardCategory, NotificationType, NotificationPriority
- Chi tiết: xem [database-schema.md](database-schema.md)

---

## Triển khai

### Yêu cầu môi trường

| Biến | Mô tả |
|------|--------|
| `DATABASE_URL` | PostgreSQL connection string |
| `JWT_SECRET` | Secret key cho JWT |
| `FIREBASE_PROJECT_ID` | Firebase project ID |
| `FIREBASE_PRIVATE_KEY` | Firebase service account key |
| `FIREBASE_CLIENT_EMAIL` | Firebase service account email |

### Docker

```bash
cd docker
docker-compose up -d    # Khởi động PostgreSQL
```
