import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App language: English or Marathi. Persisted; matches APK LanguageService / app_language.
class LanguageService extends ChangeNotifier {
  LanguageService._();

  static final LanguageService _instance = LanguageService._();
  static LanguageService get instance => _instance;

  static const String _keyLanguage = 'app_language';
  static const String en = 'en';
  static const String mr = 'mr';

  String _languageCode = en;
  String get languageCode => _languageCode;
  bool get isMarathi => _languageCode == mr;
  bool get isEnglish => _languageCode == en;
  Locale get locale => Locale(_languageCode);

  /// Load saved language from SharedPreferences. Call from main() before runApp.
  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_keyLanguage);
      if (saved != null && (saved == en || saved == mr)) {
        _languageCode = saved;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Set language (en or mr). Persists and notifies so UI rebuilds.
  Future<void> setLanguage(String code) async {
    if (code != en && code != mr) return;
    _languageCode = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguage, code);
    } catch (_) {}
    notifyListeners();
  }

  /// Toggle between English and Marathi.
  Future<void> toggleLanguage() async {
    await setLanguage(_languageCode == en ? mr : en);
  }

  /// Use for UI: returns English or Marathi string.
  String pick(String english, String marathi) {
    return _languageCode == mr ? marathi : english;
  }
}
