import 'package:flutter/material.dart';
import 'package:password_generator/services/secure_storage_service.dart';

class MasterPasswordProvider extends ChangeNotifier {
  String _masterPassword = "";

  String get masterPassword => _masterPassword;

  /// Lädt das Master-Passwort aus dem SecureStorage
  Future<void> loadMasterPassword() async {
    String? password = await SecureStorageService.getMasterPassword();

    if (password == null) {
      password = "";
      await SecureStorageService.saveMasterPassword(password);
    }

    _masterPassword = password;
    notifyListeners();
  }

  /// Speichert ein neues Master-Passwort und aktualisiert den State
  Future<void> updateMasterPassword(String newPassword) async {
    await SecureStorageService.saveMasterPassword(newPassword);
    _masterPassword = newPassword;
    notifyListeners();
  }
}
