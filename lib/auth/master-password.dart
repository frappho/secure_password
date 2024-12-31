import 'package:shared_preferences/shared_preferences.dart';

class MasterPasswordManager {
  static const String _keyMasterPassword = 'masterPassword';

  ///Speichern des Master-Passwortes
  static Future<void> saveMasterPassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMasterPassword, password);
  }

  ///Laden des Master-Passwortes
  static Future<String?> loadMasterPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? password = prefs.getString(_keyMasterPassword);

    if (password == null) {
      password = "12345";
      await prefs.setString(_keyMasterPassword, password);
    }
    return password;
  }
}