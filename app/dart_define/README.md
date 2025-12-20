# Environment Files Directory

⚠️ **DO NOT COMMIT SENSITIVE VALUES**

These files contain environment-specific configuration. Update `GOOGLE_CLIENT_ID` with your actual values.

## Files

- `dev.env` - Local development configuration
- `staging.env` - Staging environment configuration  
- `prod.env` - Production environment configuration

## Usage

```bash
# Development
flutter run --dart-define-from-file=dart_define/dev.env

# Staging
flutter run --dart-define-from-file=dart_define/staging.env

# Production
flutter run --release --dart-define-from-file=dart_define/prod.env
```

## Getting Google Client ID

1. Open Firebase Console → Project Settings
2. Download `GoogleService-Info.plist` (iOS)
3. Copy `CLIENT_ID` value
4. Update the `GOOGLE_CLIENT_ID` in each env file

## Security

Add sensitive env files to `.gitignore`:
```
dart_define/*.local.env
dart_define/*secret*
```
