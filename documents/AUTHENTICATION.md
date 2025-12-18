# Tài liệu Hệ thống Xác thực (Authentication System)

## Tổng quan
Hệ thống sử dụng cơ chế đăng nhập **Social Authentication** (Google & Apple) thông qua **Firebase Authentication**. Backend không lưu mật khẩu người dùng mà tin tưởng vào quy trình xác thực của Firebase.

## Luồng hoạt động (Authentication Flow)
1. **Client (Flutter)**: 
   - Đăng nhập với Google/Apple.
   - Nhận `idToken` từ Firebase.
   - Gửi `idToken` tới Backend qua API `POST /auth/social-login`.
2. **Backend (NestJS)**:
   - Verify `idToken` bằng Firebase Admin SDK.
   - Lấy thông tin user (uid, email, name, avatar) từ token.
   - Tạo hoặc cập nhật User trong PostgreSQL (dựa trên `firebaseUid`).
   - Tạo JWT (Access Token) riêng của hệ thống.
   - Trả về JWT và thông tin User cho Client.
3. **Protected Requests**:
   - Client gửi kèm header `Authorization: Bearer <jwt_token>` cho các request cần xác thực (VD: `GET /auth/me`).

### Diagram
```mermaid
sequenceDiagram
    participant Client as Flutter App
    participant Firebase as Firebase Auth
    participant Backend as NestJS Backend
    participant DB as PostgreSQL

    Client->>Firebase: Sign in with Google/Apple
    Firebase-->>Client: Firebase ID Token
    Client->>Backend: POST /auth/social-login { idToken }
    Backend->>Firebase: Verify ID Token
    Firebase-->>Backend: Decoded Token (uid, email, provider)
    Backend->>DB: Upsert User by firebaseUid
    DB-->>Backend: User record
    Backend->>Backend: Generate JWT
    Backend-->>Client: { accessToken, user }
    
    Note over Client,Backend: Subsequent requests
    Client->>Backend: Request with Authorization: Bearer {jwt}
    Backend->>Backend: Verify JWT
    Backend-->>Client: Protected resource
```

## Cấu hình (Configuration)

### 1. Environment Variables (`backend/.env`)
```env
# Database (Docker container running on port 5433)
DATABASE_URL="postgresql://ergolife:ergolife123@localhost:5433/ergolife_db?schema=public"

# JWT Config
JWT_SECRET=your-secret-key-here
JWT_EXPIRATION=7d

# Firebase Admin SDK
FIREBASE_CREDENTIALS_PATH=./ergolife-firebase-adminsdk.json
```

### 2. Docker Setup (`docker/`)
PostgreSQL chạy qua Docker Compose, map port **5433** ra host để tránh xung đột.
```bash
cd docker
docker compose up -d
```

## API Endpoints

### 1. Social Login
- **URL**: `/auth/social-login`
- **Method**: `POST`
- **Body**:
  ```json
  {
    "idToken": "firebase_id_token_from_client"
  }
  ```
- **Response**:
  ```json
  {
    "accessToken": "jwt_token_string",
    "user": {
      "id": "user_uuid",
      "firebaseUid": "firebase_uid",
      "email": "user@example.com",
      "provider": "GOOGLE" // hoặc "APPLE"
    }
  }
  ```

### 2. Get Current User
- **URL**: `/auth/me`
- **Method**: `GET`
- **Header**: `Authorization: Bearer <token>`
- **Response**: Thông tin User object.

## Database Schema (User Model)
File: `backend/prisma/schema.prisma`

```prisma
enum AuthProvider {
  GOOGLE
  APPLE
}

model User {
  id          String       @id @default(uuid())
  firebaseUid String       @unique @map("firebase_uid") // Khóa chính để link với Firebase
  provider    AuthProvider
  email       String?      @unique
  name        String?
  avatarId    Int?         @map("avatar_id")
  avatarUrl   String?      @map("avatar_url")
  createdAt   DateTime     @default(now()) @map("created_at")
  updatedAt   DateTime     @updatedAt @map("updated_at")

  @@map("users")
}
```

## Testing
- **Swagger UI**: [http://localhost:3000/api](http://localhost:3000/api)
- Có thể dùng Firebase Emulator hoặc Token thật từ Client App để test endpoint `/auth/social-login`.
