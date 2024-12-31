import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:password_generator/auth/master-password.dart';
import "package:password_generator/widgets/master_password_popup.dart";

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final passwordController = TextEditingController();
  String _masterPassword = "Lade ...";

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
    _loadMasterPassword();
  }

  Future<void> _loadMasterPassword() async {
    final String? password = await MasterPasswordManager.loadMasterPassword();
    setState(() {
      _masterPassword = password!;
    });
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
                  //Checkbox für Großbuchstaben
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
                  //Checkbox für Kleinbuchstaben
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
                  //Checkbox für Zahlen
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
                  //Checkbox für Symbole
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
    setState(() {
      _loadMasterPassword();
    });
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showPasswordPopup(context, _masterPassword);
              });
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
