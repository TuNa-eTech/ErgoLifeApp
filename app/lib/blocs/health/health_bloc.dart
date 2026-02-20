import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ergo_life_app/blocs/health/health_event.dart';
import 'package:ergo_life_app/blocs/health/health_state.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/repositories/health_repository.dart';

/// BLoC managing health connection state.
///
/// Supports Apple HealthKit (iOS) and Google Health
/// Connect (Android).
///
/// Handles the permission flow, including the soft-prompt
/// strategy that respects user choices and platform
/// guidelines:
/// - First prompt: when user first taps Start Session
/// - "Later" cooldown: 7 days between prompts
/// - Max prompts: 3 total, then only via Profile Settings
class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final HealthRepository _healthRepository;
  final SharedPreferences _prefs;

  static const _keyDismissCount = 'health_dismiss_count';
  static const _keyLastDismiss = 'health_last_dismiss';
  static const _keyBodyWeight = 'health_body_weight';
  static const _keyWasConnected = 'health_was_connected';
  static const _maxDismissals = 3;
  static const _cooldownDays = 7;

  HealthBloc({
    required HealthRepository healthRepository,
    required SharedPreferences prefs,
  }) : _healthRepository = healthRepository,
       _prefs = prefs,
       super(const HealthInitial()) {
    on<CheckHealthStatus>(_onCheckHealthStatus);
    on<ConnectHealth>(_onConnectHealth);
    on<DismissHealthPrompt>(_onDismissHealthPrompt);
  }

  /// Cached body weight from HealthKit or default.
  double get bodyWeight => _prefs.getDouble(_keyBodyWeight) ?? 65.0;

  Future<void> _onCheckHealthStatus(
    CheckHealthStatus event,
    Emitter<HealthState> emit,
  ) async {
    final configResult = await _healthRepository.configure();
    final configOk = configResult.fold((_) => false, (v) => v);

    if (!configOk) {
      emit(HealthDisconnected(shouldShowPrompt: _shouldShowPrompt()));
      return;
    }

    final permResult = await _healthRepository.checkPermissions();
    final hasPerms = permResult.fold((_) => null, (v) => v);

    if (hasPerms == true) {
      await _fetchAndCacheBodyWeight(emit);
      return;
    }

    // iOS returns null (unknown state). If user previously
    // connected, try reading data before showing CTA.
    final wasConnected = _prefs.getBool(_keyWasConnected) ?? false;
    if (hasPerms == null && wasConnected) {
      await _fetchAndCacheBodyWeight(emit);
      return;
    }

    emit(HealthDisconnected(shouldShowPrompt: _shouldShowPrompt()));
  }

  Future<void> _onConnectHealth(
    ConnectHealth event,
    Emitter<HealthState> emit,
  ) async {
    emit(const HealthConnecting());

    final configResult = await _healthRepository.configure();
    if (configResult.isLeft()) {
      emit(const HealthError('Health service unavailable'));
      return;
    }

    final authResult = await _healthRepository.requestAccess();
    final granted = authResult.fold((_) => false, (v) => v);

    if (granted) {
      AppLogger.success('Health connected', 'HealthBloc');
      // Persist connection + reset dismissal counter
      await _prefs.setBool(_keyWasConnected, true);
      await _prefs.setInt(_keyDismissCount, 0);
      await _fetchAndCacheBodyWeight(emit);
    } else {
      AppLogger.warning('Health authorization not granted', 'HealthBloc');
      emit(const HealthDisconnected(shouldShowPrompt: false));
    }
  }

  Future<void> _onDismissHealthPrompt(
    DismissHealthPrompt event,
    Emitter<HealthState> emit,
  ) async {
    final count = _prefs.getInt(_keyDismissCount) ?? 0;
    await _prefs.setInt(_keyDismissCount, count + 1);
    await _prefs.setString(_keyLastDismiss, DateTime.now().toIso8601String());

    AppLogger.info(
      'Health prompt dismissed (${count + 1}/$_maxDismissals)',
      'HealthBloc',
    );
    emit(const HealthDisconnected(shouldShowPrompt: false));
  }

  /// Determines if the soft prompt should be shown.
  ///
  /// Returns `true` if:
  /// - User has dismissed fewer than 3 times
  /// - At least 7 days since last dismissal
  bool _shouldShowPrompt() {
    final count = _prefs.getInt(_keyDismissCount) ?? 0;
    if (count >= _maxDismissals) return false;

    final lastDismiss = _prefs.getString(_keyLastDismiss);
    if (lastDismiss == null) return true;

    final lastDate = DateTime.tryParse(lastDismiss);
    if (lastDate == null) return true;

    final daysSince = DateTime.now().difference(lastDate).inDays;
    return daysSince >= _cooldownDays;
  }

  /// Fetches body weight and caches it locally.
  Future<void> _fetchAndCacheBodyWeight(Emitter<HealthState> emit) async {
    final weightResult = await _healthRepository.getBodyWeight();
    final weight = weightResult.fold((_) => null, (v) => v);

    if (weight != null) {
      await _prefs.setDouble(_keyBodyWeight, weight);
      AppLogger.info(
        'Cached body weight: ${weight.toStringAsFixed(1)} kg',
        'HealthBloc',
      );
    }

    emit(HealthConnected(bodyWeight: weight ?? bodyWeight));
  }
}
