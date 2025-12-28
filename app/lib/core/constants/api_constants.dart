class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.ergolife.com';
  static const String apiVersion = 'v1';

  // Auth Endpoints
  static const String socialLogin = '/auth/social-login';
  static const String authMe = '/auth/me';
  static const String logout = '/auth/logout';

  // User Endpoints
  static const String usersMe = '/users/me';
  static const String usersFcmToken = '/users/me/fcm-token';
  static const String usersById = '/users'; // + /:id

  // House Endpoints
  static const String houses = '/houses';
  static const String housesMe = '/houses/mine';
  static const String housesJoin = '/houses/join';
  static const String housesLeave = '/houses/leave';
  static const String housesInvite = '/houses/invite';
  static const String housesPreview = '/houses'; // + /:code/preview

  // Activity Endpoints
  static const String activities = '/activities';
  static const String activitiesLeaderboard = '/activities/leaderboard';
  static const String activitiesStats = '/activities/stats';

  // Reward Endpoints
  static const String rewards = '/rewards';
  static const String redemptions = '/redemptions';

  // Tasks Endpoints
  static const String tasksCustom = '/tasks/custom';

  // Headers
  static const String headerAuth = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';

  // Values
  static const String contentTypeJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';
}

