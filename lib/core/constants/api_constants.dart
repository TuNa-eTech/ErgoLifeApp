class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.ergolife.com';
  static const String apiVersion = 'v1';

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

  // Home
  static const String homeData = '/home/data';
  static const String homeStats = '/home/stats';

  // Headers
  static const String headerAuth = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';

  // Values
  static const String contentTypeJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';
}
