import "package:flutter/material.dart";
import "package:password_generator/pages/storage_page.dart";
import "package:password_generator/provider/master_password_provider.dart";
import "package:provider/provider.dart";

class MasterPasswordDialog extends StatefulWidget {
  final String masterPassword;

  const MasterPasswordDialog({
    Key? key,
    required this.masterPassword,
  }) : super(key: key);

  @override
  State<MasterPasswordDialog> createState() => _MasterPasswordDialogState();
}

class _MasterPasswordDialogState extends State<MasterPasswordDialog> {
  late final TextEditingController _passwordController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _focusNode = FocusNode();

    // Request focus after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validatePassword() {
    if (_passwordController.text == widget.masterPassword) {
      Navigator.of(context).pop(true); // Return true for successful validation
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Falsches Passwort!")),
      );
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: AlertDialog(
        title: const Text("Eingabe Master-Passwort"),
        content: TextField(
          focusNode: _focusNode,
          controller: _passwordController,
          obscureText: true,
          onSubmitted: (_) => _validatePassword(),
          decoration: const InputDecoration(
            labelText: "Master-Passwort",
            labelStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "Abbrechen",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: _validatePassword,
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

void showPasswordPopup(BuildContext context) async {
  final masterPassword = context.read<MasterPasswordProvider>().masterPassword;

  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => MasterPasswordDialog(masterPassword: masterPassword),
  );

  if (result == true && context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PasswordStoragePage(),
      ),
    );
  }
}
