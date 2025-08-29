import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeProvider() {
    _load();
  }

  ThemeMode get mode => _mode;

  Future<void> toggle(bool isDark) async {
    _mode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _mode.name);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode');
    if (saved != null) {
      _mode = ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
      notifyListeners();
    }
  }
}


