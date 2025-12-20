/// Application configuration with environment variable support
/// Uses --dart-define for runtime configuration
class AppConfig {
  static const String appName = 'ErgoLife';
  static const String appVersion = '1.0.0';

  // Environment variables from dart-define
  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const String _googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Derived environment
  static Environment get environment {
    switch (_environment.toLowerCase()) {
      case 'production':
        return Environment.production;
      case 'staging':
        return Environment.staging;
      default:
        return Environment.development;
    }
  }

  // API Configuration
  static String get baseUrl => _apiUrl;

  // Google Sign-In Configuration
  static String get googleClientId => _googleClientId;

  // Timeout Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableCrashReporting = false;
}

enum Environment { development, staging, production }
