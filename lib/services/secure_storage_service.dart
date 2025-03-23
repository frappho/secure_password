import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _masterPasswordKey = 'master_password';

  // Save master password
  static Future<void> saveMasterPassword(String password) async {
    await _storage.write(key: _masterPasswordKey, value: password);
  }

  // Retrieve master password
  static Future<String?> getMasterPassword() async {
    return await _storage.read(key: _masterPasswordKey);
  }

  // Delete master password
  static Future<void> deleteMasterPassword() async {
    await _storage.delete(key: _masterPasswordKey);
  }

  // Check if master password exists
  static Future<bool> hasMasterPassword() async {
    final value = await _storage.read(key: _masterPasswordKey);
    return value != null;
  }

  // Delete all secure storage data
  static Future<void> deleteAllSecureData() async {
    await _storage.deleteAll();
  }
} 