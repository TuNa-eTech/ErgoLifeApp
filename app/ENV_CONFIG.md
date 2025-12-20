# Flutter Environment Configuration with dart-define

## 📝 Overview

App này sử dụng `--dart-define-from-file` để quản lý environment variables từ file. Đơn giản và native Flutter.

## 🔧 Environment Variables

### Available Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `API_URL` | Backend API base URL | `http://localhost:3000` | Yes |
| `GOOGLE_CLIENT_ID` | Google Sign-In iOS Client ID | `''` (empty) | Yes for Google Auth |
| `ENVIRONMENT` | Environment name | `development` | No |

## 📁 Environment Files

Các file environment được lưu trong thư mục `dart_define/`:

- **`dev.env`** - Local development
- **`staging.env`** - Staging environment
- **`prod.env`** - Production environment

### File Format

```env
API_URL=http://localhost:3000
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
ENVIRONMENT=development
```

## 🚀 Usage

### Development (Local)

```bash
flutter run --dart-define-from-file=dart_define/dev.env
```

### Staging

```bash
flutter run --dart-define-from-file=dart_define/staging.env
```

### Production

```bash
flutter run --release --dart-define-from-file=dart_define/prod.env
```

## 💡 VS Code Configuration

Tạo file `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "toolArgs": [
        "--dart-define-from-file=dart_define/dev.env"
      ]
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "toolArgs": [
        "--dart-define-from-file=dart_define/staging.env"
      ]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "toolArgs": [
        "--dart-define-from-file=dart_define/prod.env"
      ]
    }
  ]
}
```

## 📦 Build Commands

### Android APK

```bash
# Production
flutter build apk --dart-define-from-file=dart_define/prod.env

# Staging
flutter build apk --dart-define-from-file=dart_define/staging.env
```

### iOS

```bash
# Production
flutter build ios --release --dart-define-from-file=dart_define/prod.env

# Staging
flutter build ios --release --dart-define-from-file=dart_define/staging.env
```

## 🔐 Getting Google Client ID

1. Mở Firebase Console → Project Settings
2. Scroll xuống phần "Your apps"
3. Chọn iOS app
4. Download `GoogleService-Info.plist`
5. Mở file và copy giá trị `CLIENT_ID`
6. Update vào file env tương ứng

## 📋 Access trong Code

```dart
import 'package:ergo_life_app/core/config/app_config.dart';

// Sử dụng các config
final apiUrl = AppConfig.baseUrl;
final googleClientId = AppConfig.googleClientId;
final env = AppConfig.environment; // Environment enum
```

## ⚠️ Important Notes

1. **Không commit sensitive values** - Add `.env` files vào `.gitignore` nếu chứa sensitive data
2. **Template files** - Có thể commit template files (như `dev.env` với placeholder values)
3. **Google Client ID khác nhau** cho iOS và Android
4. **Mỗi environment** nên có riêng Google OAuth Client
5. **Default values** được set trong `AppConfig` để app vẫn chạy được

## 🛡️ Security Best Practices

Add vào `.gitignore`:
```gitignore
# Sensitive environment files
dart_define/*.local.env
dart_define/*secret*
```

Hoặc commit template và tạo local copy:
```bash
cp dart_define/dev.env dart_define/dev.local.env
# Edit dev.local.env với real values
```

## 🔍 Verify Configuration

Add vào `main.dart` để verify:

```dart
void main() {
  print('🔧 Configuration:');
  print('   API URL: ${AppConfig.baseUrl}');
  print('   Environment: ${AppConfig.environment}');
  print('   Google Client ID: ${AppConfig.googleClientId.isNotEmpty ? "✅ Configured" : "❌ Missing"}');
  
  runApp(MyApp());
}
```

## 🎯 Quick Start

1. Update Google Client ID trong các env files:
   ```bash
   # Edit dart_define/dev.env
   GOOGLE_CLIENT_ID=your-actual-client-id.apps.googleusercontent.com
   ```

2. Run with environment:
   ```bash
   flutter run --dart-define-from-file=dart_define/dev.env
   ```

3. Verify trong logs khi app khởi động

