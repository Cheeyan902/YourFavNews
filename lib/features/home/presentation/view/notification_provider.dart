import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  bool _isEnabled = false;
  int _intervalMinutes = 10; // default

  bool get isEnabled => _isEnabled;
  int get intervalMinutes => _intervalMinutes;

  NotificationProvider() {
    _loadPrefs();
  }

  void toggle(bool value) async {
    _isEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  void setInterval(int minutes) async {
    _intervalMinutes = minutes;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_interval', minutes);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('notifications_enabled') ?? false;
    _intervalMinutes = prefs.getInt('notification_interval') ?? 10;
    notifyListeners();
  }
}
