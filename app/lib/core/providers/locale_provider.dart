import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('vi'); // Default to Vietnamese

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'vi') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('vi'));
    }
  }
}
