import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadTheme(); // Load saved theme when provider is created
  }

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? darkMode : lightMode;
    notifyListeners();

    // Save the user's choice
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeData = _isDarkMode ? darkMode : lightMode;
    notifyListeners();
  }
}
