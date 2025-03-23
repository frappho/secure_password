import 'package:flutter/material.dart';
import 'package:password_generator/services/secure_storage_service.dart';

class MasterPasswordManager {
  ///Speichern des Master-Passwortes
  static Future<void> saveMasterPassword(String password) async {
    await SecureStorageService.saveMasterPassword(password);
  }

  ///Laden des Master-Passwortes
  static Future<String?> loadMasterPassword(BuildContext context) async {
    String? password = await SecureStorageService.getMasterPassword();

    if (password == null) {
      password = "";
      await SecureStorageService.saveMasterPassword(password);
    }
    return password;
  }
}