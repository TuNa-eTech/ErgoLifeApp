class AppConfig {
  static const String appName = 'ErgoLife';
  static const String appVersion = '1.0.0';

  // Environment
  static const Environment environment = Environment.development;

  // API Configuration
  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return 'https://api-dev.ergolife.com';
      case Environment.staging:
        return 'https://api-staging.ergolife.com';
      case Environment.production:
        return 'https://api.ergolife.com';
    }
  }

  // Timeout Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableCrashReporting = false;
}

enum Environment { development, staging, production }
