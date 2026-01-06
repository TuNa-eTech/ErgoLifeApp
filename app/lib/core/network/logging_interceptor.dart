import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

/// Interceptor to log all API requests, responses, and errors
class LoggingInterceptor extends Interceptor {
  static const String _tag = 'API';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('', _tag);
    AppLogger.info('┌─────────────────────────────────────────────────', _tag);
    AppLogger.info('│ 📤 REQUEST', _tag);
    AppLogger.info('├─────────────────────────────────────────────────', _tag);
    AppLogger.info('│ ${options.method} ${options.uri}', _tag);
    
    if (options.queryParameters.isNotEmpty) {
      AppLogger.info('│ Query: ${options.queryParameters}', _tag);
    }
    
    if (options.headers.isNotEmpty) {
      AppLogger.info('│ Headers:', _tag);
      options.headers.forEach((key, value) {
        // Mask sensitive headers
        final displayValue = _maskSensitiveData(key, value.toString());
        AppLogger.info('│   $key: $displayValue', _tag);
      });
    }
    
    if (options.data != null) {
      AppLogger.info('│ Body:', _tag);
      AppLogger.info('│   ${_formatData(options.data)}', _tag);
    }
    
    AppLogger.info('└─────────────────────────────────────────────────', _tag);
    AppLogger.info('', _tag);
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info('', _tag);
    AppLogger.info('┌─────────────────────────────────────────────────', _tag);
    AppLogger.info('│ 📥 RESPONSE', _tag);
    AppLogger.info('├─────────────────────────────────────────────────', _tag);
    AppLogger.info('│ ${response.requestOptions.method} ${response.requestOptions.uri}', _tag);
    AppLogger.info('│ Status: ${response.statusCode} ${response.statusMessage}', _tag);
    
  //  if (response.headers.map.isNotEmpty) {
  //     AppLogger.info('│ Headers:', _tag);
  //     response.headers.map.forEach((key, value) {
  //       AppLogger.info('│   $key: ${value.join(", ")}', _tag);
  //     });
  //   }
    
    if (response.data != null) {
      AppLogger.info('│ Data:', _tag);
      AppLogger.info('│   ${_formatData(response.data)}', _tag);
    }
    
    AppLogger.info('└─────────────────────────────────────────────────', _tag);
    AppLogger.info('', _tag);
    
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.info('', _tag);
    AppLogger.info('┌─────────────────────────────────────────────────', _tag);
    AppLogger.error('│ ❌ ERROR', _tag);
    AppLogger.info('├─────────────────────────────────────────────────', _tag);
    AppLogger.error('│ ${err.requestOptions.method} ${err.requestOptions.uri}', _tag);
    AppLogger.error('│ Type: ${err.type}', _tag);
    AppLogger.error('│ Message: ${err.message}', _tag);
    
    if (err.response != null) {
      AppLogger.error('│ Status: ${err.response?.statusCode}', _tag);
      AppLogger.error('│ Data: ${_formatData(err.response?.data)}', _tag);
    }
    
    if (err.stackTrace != null) {
      AppLogger.error('│ StackTrace:', _tag);
      final stackLines = err.stackTrace.toString().split('\n').take(5);
      for (final line in stackLines) {
        AppLogger.error('│   $line', _tag);
      }
    }
    
    AppLogger.info('└─────────────────────────────────────────────────', _tag);
    AppLogger.info('', _tag);
    
    super.onError(err, handler);
  }

  /// Mask sensitive data in headers
  String _maskSensitiveData(String key, String value) {
    final lowerKey = key.toLowerCase();
    
    if (lowerKey.contains('authorization') ||
        lowerKey.contains('token') ||
        lowerKey.contains('api-key') ||
        lowerKey.contains('apikey')) {
      if (value.isEmpty) return '(empty)';
      if (value.length <= 10) return '***';
      
      // Show first 10 and last 4 characters
      return '${value.substring(0, 10)}...${value.substring(value.length - 4)}';
    }
    
    return value;
  }

  /// Format data for logging (pretty print JSON if possible)
  String _formatData(dynamic data) {
    try {
      if (data == null) return 'null';
      
      if (data is Map || data is List) {
        // Pretty print JSON with indentation
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      }
      
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }
}
