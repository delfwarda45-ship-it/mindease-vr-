import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  bool _isLoading = false;

  Locale get locale => _locale;
  bool get isLoading => _isLoading;

  LanguageProvider() {
    _loadSavedLocale();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    if (locale.countryCode != null) {
      await prefs.setString('country_code', locale.countryCode!);
    }

    notifyListeners();
  }

  Future<void> _loadSavedLocale() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'ar';
      final countryCode = prefs.getString('country_code');

      _locale = countryCode != null
          ? Locale(languageCode, countryCode)
          : Locale(languageCode);
    } catch (e) {
      _locale = const Locale('ar');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
