import "package:flutter/material.dart";
import "package:password_generator/pages/storage_page.dart";
import 'package:password_generator/auth/master-password.dart';

void showPasswordPopup(BuildContext context, String masterPassword) {
  final TextEditingController passwordController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  //const String masterPassword = "1708"; // Vordefiniertes Master-Passwort

  void _validatePassword(BuildContext context) {
    if (passwordController.text == masterPassword) {
      Navigator.of(context).pop(); // Schließt das Popup
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PasswordStoragePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Falsches Passwort!")),
      );
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Eingabe Master-Passwort"),
        content: TextField(
          focusNode: focusNode,
          // Verknüpft den Fokus mit dem TextField
          onSubmitted: (value) {
            _validatePassword(context);
          },
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Master-Passwort",
            labelStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Schließt das Popup
            },
            child: const Text(
              "Abbrechen",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              _validatePassword(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  ).then((_) {
    focusNode.dispose(); // Freigeben des Fokus, wenn der Dialog geschlossen wird
    passwordController.dispose();
  });

  // Setze den Fokus nach der Anzeige des Dialogs
  WidgetsBinding.instance.addPostFrameCallback((_) {
    focusNode.requestFocus();
  });
}
