import 'dart:io';
import 'package:live_activities/live_activities.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

/// Service that manages iOS Live Activities for active sessions.
///
/// Shows the session timer on the Lock Screen and Dynamic Island
/// so users can track their session even when the app is
/// backgrounded.
class LiveActivityService {
  static const _appGroupId = 'group.com.anhtu.ergolife';
  static const _tag = 'LiveActivityService';

  final LiveActivities _liveActivities = LiveActivities();
  String? _currentActivityId;

  /// Initialize the Live Activity plugin.
  Future<void> init() async {
    if (!Platform.isIOS) return;
    try {
      await _liveActivities.init(appGroupId: _appGroupId);
      AppLogger.info('Initialized', _tag);
    } catch (e) {
      AppLogger.error('Failed to init', '$e', null, _tag);
    }
  }

  /// Start a Live Activity for the given session.
  Future<void> startSessionActivity({
    required String taskName,
    required int targetSeconds,
  }) async {
    if (!Platform.isIOS) return;
    try {
      // End any existing activity first
      await endSessionActivity();

      final data = <String, dynamic>{
        'taskName': taskName,
        'targetSeconds': targetSeconds,
        'elapsedSeconds': 0,
        'isPaused': false,
        // Epoch ms for native timer — reliable across Dart/Swift
        'startedAtMs': DateTime.now().millisecondsSinceEpoch,
      };

      final activityId =
          'ergo_session_${DateTime.now().millisecondsSinceEpoch}';

      AppLogger.info('Creating activity "$activityId" with data: $data', _tag);

      _currentActivityId = await _liveActivities.createActivity(
        activityId,
        data,
      );
      AppLogger.info('Activity created, id: $_currentActivityId', _tag);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to start activity', '$e', stackTrace, _tag);
    }
  }

  /// Update the Live Activity with current session data.
  Future<void> updateSessionActivity({
    required int elapsedSeconds,
    required bool isPaused,
  }) async {
    if (!Platform.isIOS || _currentActivityId == null) return;
    try {
      // Recalculate virtualStart so the native SwiftUI timer
      // stays in sync: virtualStart = now - elapsed
      final virtualStart = DateTime.now().subtract(
        Duration(seconds: elapsedSeconds),
      );

      final data = <String, dynamic>{
        'elapsedSeconds': elapsedSeconds,
        'isPaused': isPaused,
        'startedAtMs': virtualStart.millisecondsSinceEpoch,
      };

      await _liveActivities.updateActivity(_currentActivityId!, data);
    } catch (e) {
      // Silently fail on update — not critical
    }
  }

  /// End the current Live Activity.
  Future<void> endSessionActivity() async {
    if (!Platform.isIOS) return;
    try {
      if (_currentActivityId != null) {
        await _liveActivities.endActivity(_currentActivityId!);
        AppLogger.info('Ended activity', _tag);
        _currentActivityId = null;
      }
    } catch (e) {
      AppLogger.error('Failed to end activity', '$e', null, _tag);
      _currentActivityId = null;
    }
  }

  /// End all active Live Activities.
  Future<void> endAllActivities() async {
    if (!Platform.isIOS) return;
    try {
      await _liveActivities.endAllActivities();
      _currentActivityId = null;
    } catch (e) {
      // Silently fail
    }
  }
}
