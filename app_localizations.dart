import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, dynamic>? _localizedStrings;

  Future<bool> load() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/languages/${locale.languageCode}.json');
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      _localizedStrings = jsonMap;

      return true;
    } catch (e) {
      print('Error loading language file: $e');
      final fallbackJson =
          await rootBundle.loadString('assets/languages/en.json');
      final jsonMap = json.decode(fallbackJson) as Map<String, dynamic>;

      _localizedStrings = jsonMap;

      return true;
    }
  }

  String? tryTranslate(String key) {
    final value = _localizedStrings?[key];
    return value?.toString();
  }

  String translate(String key) {
    final value = _localizedStrings?[key];
    return value?.toString() ?? '**$key**';
  }

  List<String>? getList(String key) {
    final value = _localizedStrings?[key];
    if (value is List) {
      return value.cast<String>();
    }
    return null;
  }

  Map<String, String>? getMap(String key) {
    final value = _localizedStrings?[key];
    if (value is Map) {
      return value.cast<String, String>();
    }
    return null;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
