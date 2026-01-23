import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's locale state with persistent storage.
///
/// **Behavior:**
/// 1. First launch: Auto-detects device language (Vietnamese → VI, Others → EN)
/// 2. User changes language: Saves preference to SharedPreferences
/// 3. Subsequent launches: Loads saved preference (ignores device language)
///
/// This ensures the app respects user's language choice across sessions.
class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'user_selected_locale';

  LocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  /// Loads saved locale preference or auto-detects device language.
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);

      if (savedLocaleCode != null) {
        // User has previously selected a language - use it
        emit(Locale(savedLocaleCode));
      } else {
        // First launch - auto-detect device language
        final deviceLocale = ui.PlatformDispatcher.instance.locale;

        if (deviceLocale.languageCode == 'vi') {
          emit(const Locale('vi'));
        } else {
          emit(const Locale('en'));
        }
      }
    } catch (e) {
      // If error, fallback to English
      emit(const Locale('en'));
    }
  }

  /// Sets locale and saves to SharedPreferences.
  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _saveLocale(locale.languageCode);
  }

  /// Toggles between English and Vietnamese, and saves preference.
  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'vi'
        ? const Locale('en')
        : const Locale('vi');
    emit(newLocale);
    await _saveLocale(newLocale.languageCode);
  }

  /// Saves locale preference to SharedPreferences.
  Future<void> _saveLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
    } catch (e) {
      // Silently fail - user preference won't be saved but app continues
    }
  }
}
