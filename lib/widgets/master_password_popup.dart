import "package:flutter/material.dart";
import "package:password_generator/pages/storage_page.dart";

void showPasswordPopup(BuildContext context, String masterPassword) {
  final TextEditingController passwordController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void _validatePassword(BuildContext context) {
    if (passwordController.text == masterPassword) {
      Navigator.of(context).pop();
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
              Navigator.of(context).pop();
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
    focusNode.dispose();
    passwordController.dispose();
  });


  WidgetsBinding.instance.addPostFrameCallback((_) {
    focusNode.requestFocus();
  });
}
