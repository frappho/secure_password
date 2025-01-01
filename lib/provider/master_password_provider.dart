import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MasterPasswordProvider extends ChangeNotifier {
  static const String _keyMasterPassword = 'masterPassword';
  String _masterPassword = "";

  String get masterPassword => _masterPassword;

  /// Lädt das Master-Passwort aus den SharedPreferences
  Future<void> loadMasterPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? password = prefs.getString(_keyMasterPassword);

    if (password == null) {
      password = "";
      await prefs.setString(_keyMasterPassword, password);
    }

    _masterPassword = password;
    notifyListeners();
  }

  /// Speichert ein neues Master-Passwort und aktualisiert den State
  Future<void> updateMasterPassword(String newPassword) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMasterPassword, newPassword);
    _masterPassword = newPassword;
    notifyListeners();
  }
}
