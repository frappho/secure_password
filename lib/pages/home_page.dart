import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:password_generator/auth/master-password.dart';
import 'package:password_generator/pages/storage_page.dart';
import 'package:password_generator/provider/master_password_provider.dart';
import "package:password_generator/widgets/master_password_popup.dart";
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  bool uppercaseBool = true;
  bool lowercaseBool = true;
  bool numberBool = true;
  bool specialsBool = true;
  int length = 8;

  @override
  void initState() {
    super.initState();
    _loadMasterPassword(context);
  }

  Future<void> _loadMasterPassword(BuildContext context) async {
    final String? password = await MasterPasswordManager.loadMasterPassword(context);
  }

  Future<void> _saveMasterPassword(String masterPassword) async {
    await MasterPasswordManager.saveMasterPassword(masterPassword);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Neues Master-Passwort gespeichert!"),
      ),
    );
  }

  Future<void> _initializeMasterPassword(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController passwordConfirmController = TextEditingController();
    final FocusNode passwordFocus = FocusNode();
    final FocusNode passwordConfirmFocus = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Neues Master-Passwort'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                focusNode: passwordFocus,
                textInputAction: TextInputAction.done,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Passwort',
                  labelStyle: const TextStyle(color: Colors.blueGrey),
                ),
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(passwordConfirmFocus);
                },
              ),
              TextField(
                controller: passwordConfirmController,
                focusNode: passwordConfirmFocus,
                textInputAction: TextInputAction.done,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Passwort bestätigen',
                  labelStyle: const TextStyle(color: Colors.blueGrey),
                ),
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (passwordController.text == passwordConfirmController.text) {
                  context.read<MasterPasswordProvider>().updateMasterPassword(passwordController.text);
                  //_saveMasterPassword(passwordController.text);
                  Navigator.of(context).pop(passwordController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwörter nicht identisch!")),
                  );
                  passwordController.clear();
                  passwordConfirmController.clear();
                  FocusScope.of(context).requestFocus(passwordFocus);
                }
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  checkBoxLetters(bool leftValue, bool rightValue, String leftString, String rightString, bool leftValueNum, bool rightValueSym, String leftStringNum, String rightStringSym) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(leftString),
                Checkbox(
                  value: leftValue,
                  onChanged: (value) {
                    setState(
                      () {
                        leftValue = !leftValue;
                        uppercaseBool = value!;
                      },
                    );
                  },
                  fillColor: WidgetStateProperty.resolveWith(
                    (Set states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.greenAccent;
                      }
                      return Colors.transparent;
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(rightString),
                Checkbox(
                  value: rightValue,
                  onChanged: (value) {
                    setState(
                      () {
                        rightValue = !rightValue;
                        lowercaseBool = value!;
                        print(value);
                      },
                    );
                  },
                  fillColor: WidgetStateProperty.resolveWith(
                    (Set states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.greenAccent;
                      }
                      return Colors.transparent;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(leftStringNum),
                Checkbox(
                  value: leftValueNum,
                  onChanged: (value) {
                    setState(
                      () {
                        leftValueNum = !leftValueNum;
                        numberBool = value!;
                        print(value);
                      },
                    );
                  },
                  fillColor: WidgetStateProperty.resolveWith(
                    (Set states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.greenAccent;
                      }
                      return Colors.transparent;
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(rightStringSym),
                Checkbox(
                  value: rightValueSym,
                  onChanged: (value) {
                    setState(
                      () {
                        rightValueSym = !rightValueSym;
                        specialsBool = value!;
                        print(value);
                      },
                    );
                  },
                  fillColor: WidgetStateProperty.resolveWith(
                    (Set states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.greenAccent;
                      }
                      return Colors.transparent;
                    },
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  String generatePassword({
    int length = 8,
    bool uppercaseBool = true,
    bool lowercaseBool = false,
    bool numbersBool = false,
    bool specialsBool = false,
  }) {
    final lowercase = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
    final uppercase = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
    final numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
    final specials = ["@", "#", "=", "+", "!", "?", "%", "&", "(", ")", "{", "}", "[", "]", "€"];
    final random = Random();

    int randInt = 0;
    String chars = "";

    for (var i = 0; i < length;) {
      if (uppercaseBool == true) {
        randInt = random.nextInt(uppercase.length);
        chars += uppercase[randInt];
        i++;
        if (i >= length) {
          break;
        }
      }
      if (lowercaseBool == true) {
        randInt = random.nextInt(lowercase.length);
        chars += lowercase[randInt];
        i++;
        if (i >= length) {
          break;
        }
      }
      if (numbersBool == true) {
        randInt = random.nextInt(numbers.length);
        chars += numbers[randInt];
        i++;
        if (i >= length) {
          break;
        }
      }
      if (specialsBool == true) {
        randInt = random.nextInt(specials.length);
        chars += specials[randInt];
        i++;
        if (i >= length) {
          break;
        }
      }
    }
    return chars;
  }

  lengthBox(value) {
    return ElevatedButton(
      child: Text(
        value.toString(),
        style: TextStyle(fontSize: 20),
      ),
      onPressed: () {
        setState(() {
          length = value;
        });
        print("Länge: $length");
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(length == value ? Colors.blueGrey : Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterPassword = context.watch<MasterPasswordProvider>().masterPassword;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              if (masterPassword.isEmpty) {
                _initializeMasterPassword(context);
              } else {
                showPasswordPopup(context);
              };
            },
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
          ),
        ],
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.greenAccent],
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Einstellungen',
              style: TextStyle(fontFamily: "Arial", fontSize: 30, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Text("Länge Passwort:"),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    lengthBox(8),
                    lengthBox(10),
                    lengthBox(15),
                    lengthBox(20),
                  ],
                ),
                checkBoxLetters(uppercaseBool, lowercaseBool, "Großbuchstaben", "Kleinbuchstaben", numberBool, specialsBool, "Zahlen", "Symbole"),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                  child: TextField(
                    readOnly: true,
                    controller: passwordController,
                    keyboardType: TextInputType.none,
                    enableInteractiveSelection: false,
                    showCursor: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: passwordController.text));
                        },
                        icon: const Icon(Icons.copy),
                      ),
                    ),
                    autofocus: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (uppercaseBool == false && lowercaseBool == false && numberBool == false && specialsBool == false) {
                      setState(() {
                        uppercaseBool = true;
                      });
                    }
                    ;
                    final password = generatePassword(length: length, uppercaseBool: uppercaseBool, lowercaseBool: lowercaseBool, numbersBool: numberBool, specialsBool: specialsBool);

                    passwordController.text = password;
                  },
                  child: const Text(
                    "Generieren",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
