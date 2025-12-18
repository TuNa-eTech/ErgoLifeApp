import 'package:ergo_life_app/data/models/session_model.dart';
import 'package:ergo_life_app/data/services/api_service.dart';

class SessionRepository {
  final ApiService _apiService;

  SessionRepository(this._apiService);

  // Get active sessions
  Future<List<SessionModel>> getActiveSessions() async {
    try {
      final response = await _apiService.get('/sessions/active');
      final List<dynamic> data = response.data['sessions'];
      return data.map((json) => SessionModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get session history
  Future<List<SessionModel>> getSessionHistory() async {
    try {
      final response = await _apiService.get('/sessions/history');
      final List<dynamic> data = response.data['sessions'];
      return data.map((json) => SessionModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Start a new session
  Future<SessionModel> startSession({
    required String title,
    required String description,
  }) async {
    try {
      final response = await _apiService.post(
        '/sessions/start',
        data: {'title': title, 'description': description},
      );
      return SessionModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // End a session
  Future<SessionModel> endSession(String sessionId) async {
    try {
      final response = await _apiService.post('/sessions/$sessionId/end');
      return SessionModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Pause a session
  Future<SessionModel> pauseSession(String sessionId) async {
    try {
      final response = await _apiService.post('/sessions/$sessionId/pause');
      return SessionModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Resume a session
  Future<SessionModel> resumeSession(String sessionId) async {
    try {
      final response = await _apiService.post('/sessions/$sessionId/resume');
      return SessionModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Get mock sessions for demo
  List<SessionModel> getMockSessions() {
    final now = DateTime.now();
    return [
      SessionModel(
        id: '1',
        title: 'Morning Session',
        description: 'Morning posture tracking',
        duration: 3600,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1)),
        status: 'completed',
      ),
      SessionModel(
        id: '2',
        title: 'Afternoon Session',
        description: 'Afternoon work session',
        duration: 1800,
        startTime: now.subtract(const Duration(minutes: 30)),
        status: 'active',
      ),
    ];
  }
}
