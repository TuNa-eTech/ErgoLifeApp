import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('vi')); // Default to Vietnamese

  void setLocale(Locale locale) {
    emit(locale);
  }

  void toggleLocale() {
    if (state.languageCode == 'vi') {
      emit(const Locale('en'));
    } else {
      emit(const Locale('vi'));
    }
  }
}
