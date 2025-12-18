import 'package:flutter/foundation.dart';

class AppLogger {
  static const bool _enableLogging = kDebugMode;

  static void debug(String message, [String? tag]) {
    if (_enableLogging) {
      print('🐛 ${tag != null ? '[$tag] ' : ''}$message');
    }
  }

  static void info(String message, [String? tag]) {
    if (_enableLogging) {
      print('ℹ️  ${tag != null ? '[$tag] ' : ''}$message');
    }
  }

  static void warning(String message, [String? tag]) {
    if (_enableLogging) {
      print('⚠️  ${tag != null ? '[$tag] ' : ''}$message');
    }
  }

  static void error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    if (_enableLogging) {
      print('❌ ${tag != null ? '[$tag] ' : ''}$message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('Stack trace: $stackTrace');
    }
  }

  static void success(String message, [String? tag]) {
    if (_enableLogging) {
      print('✅ ${tag != null ? '[$tag] ' : ''}$message');
    }
  }
}
