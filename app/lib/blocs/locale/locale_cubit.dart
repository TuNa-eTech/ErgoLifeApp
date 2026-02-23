import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ergo_life_app/core/di/service_locator.dart';
import 'package:ergo_life_app/core/network/api_client.dart';

/// Manages the app's locale state with persistent storage.
///
/// **Behavior:**
/// 1. First launch: Auto-detects device language
///    (Vietnamese → VI, Others → EN)
/// 2. User changes language: Saves preference to
///    SharedPreferences
/// 3. Subsequent launches: Loads saved preference
///    (ignores device language)
///
/// Syncs the locale with [ApiClient] so all API
/// requests include the correct `Accept-Language`
/// header.
class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'user_selected_locale';

  LocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  /// Loads saved locale or auto-detects device
  /// language.
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);

      if (savedLocaleCode != null) {
        _applyLocale(Locale(savedLocaleCode));
      } else {
        final deviceLocale = ui.PlatformDispatcher.instance.locale;
        if (deviceLocale.languageCode == 'vi') {
          _applyLocale(const Locale('vi'));
        } else {
          _applyLocale(const Locale('en'));
        }
      }
    } catch (e) {
      _applyLocale(const Locale('en'));
    }
  }

  /// Sets locale, syncs with API, and persists.
  Future<void> setLocale(Locale locale) async {
    _applyLocale(locale);
    await _saveLocale(locale.languageCode);
  }

  /// Toggles between English and Vietnamese.
  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'vi'
        ? const Locale('en')
        : const Locale('vi');
    _applyLocale(newLocale);
    await _saveLocale(newLocale.languageCode);
  }

  /// Emits locale and syncs with API client.
  void _applyLocale(Locale locale) {
    emit(locale);
    sl<ApiClient>().setLocale(locale.languageCode);
  }

  /// Saves locale preference to SharedPreferences.
  Future<void> _saveLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
    } catch (e) {
      // Silently fail
    }
  }
}
