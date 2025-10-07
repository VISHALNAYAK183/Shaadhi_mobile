import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    String? savedLanguage = await getOldLanguage();
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("oldLanguage", languageCode);
    notifyListeners();
  }

  Future<String?> getOldLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("oldLanguage");
  }
}
