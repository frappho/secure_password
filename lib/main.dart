import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:password_generator/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeEncryptedFile();
  runApp(const MyApp());
}

Future<void> initializeEncryptedFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/data.enc');

  if (!await file.exists() || (await file.readAsBytes()).isEmpty) {
    print("Datei existiert nicht oder ist leer. Neue Datei wird erstellt.");
    final emptyData = jsonEncode([]);
    final encryptedData = encryptData(emptyData);
    await file.writeAsBytes(encryptedData);
  }
}

List<int> encryptData(String plainText) {
  final key = encrypt.Key.fromUtf8('a1w63d1a3d1ad8ad43wa3daw34da4dg1'); // 32 signs
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.bytes;
}

String decryptData(List<int> encryptedBytes) {
  final key = encrypt.Key.fromUtf8('a1w63d1a3d1ad8ad43wa3daw34da4dg1'); // 32 signs
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  // Konvertiere List<int> zu Uint8List
  final encrypted = encrypt.Encrypted(Uint8List.fromList(encryptedBytes));

  return encrypter.decrypt(encrypted, iv: iv);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Generator',
      theme: ThemeData(
        primaryColor: Colors.grey,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.greenAccent
        ),
        inputDecorationTheme: InputDecorationTheme(

          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.greenAccent),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.greenAccent,
          ),
        ),
        brightness: Brightness.dark,
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.black),
            backgroundColor: WidgetStatePropertyAll(Colors.grey),
          ),
        ),
        checkboxTheme: const CheckboxThemeData(
          checkColor: WidgetStatePropertyAll(Colors.black),
        ),
      ),
      home: const MyHomePage(title: 'Passwort',),
    );
  }
}
