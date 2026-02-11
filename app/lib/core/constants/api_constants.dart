class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.ergolife.com';
  static const String apiVersion = 'v1';

  // Auth Endpoints
  static const String socialLogin = '/auth/social-login';
  static const String authMe = '/auth/me';
  static const String logout = '/auth/logout';
  static const String deleteAccount = '/auth/account';

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
  static const String tasks = '/tasks';
  static const String tasksCustom = '/tasks/custom';
  static const String tasksSeed = '/tasks/seed';
  static const String tasksReorder = '/tasks/reorder';
  static const String tasksNeedsSeeding = '/tasks/needs-seeding';

  // Task Templates Endpoints
  static const String taskTemplates = '/task-templates';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String notificationById(String id) => '/notifications/$id';
  static String notificationMarkAsRead(String id) => '/notifications/$id/read';

  // Gift Endpoints
  static const String giftsCatalog = '/gifts/catalog';
  static const String giftsSend = '/gifts/send';
  static const String giftsHistory = '/gifts/history';

  // Headers
  static const String headerAuth = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';

  // Values
  static const String contentTypeJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';
}
