import "dart:typed_data";
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:password_generator/provider/master_password_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:password_generator/auth/master-password.dart';
import 'package:provider/provider.dart';

class PasswordStoragePage extends StatefulWidget {
  const PasswordStoragePage({super.key});

  @override
  State<PasswordStoragePage> createState() => _PasswordStoragePageState();
}

class _PasswordStoragePageState extends State<PasswordStoragePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filteredData = [];
  //String? _masterPassword;

  @override
  void initState() {
    super.initState();
    _initializeFile().then((_) => _loadData());
    //_loadMasterPassword();
  }

  Future<void> _initializeFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.enc');

    if (!await file.exists() || (await file.readAsBytes()).isEmpty) {
      print("Datei existiert nicht oder ist leer. Neue Datei wird erstellt.");
      final emptyData = jsonEncode([]);
      final encryptedData = encryptData(emptyData);
      await file.writeAsBytes(encryptedData);
    }
  }

  Future<void> _loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data.enc');

      if (await file.exists()) {
        final encryptedBytes = await file.readAsBytes();
        print("Rohdaten (verschlüsselt): $encryptedBytes");

        final decryptedData = decryptData(encryptedBytes);
        print("Rohdaten (entschlüsselt): $decryptedData");

        final List<Map<String, dynamic>> decodedData = List<Map<String, dynamic>>.from(jsonDecode(decryptedData));
        setState(() {
          _data = decodedData;
          _filteredData = List.from(_data);
        });
      } else {
        print("Datei existiert nicht.");
      }
    } catch (e) {
      print("Fehler beim Laden der Daten: $e");
    }
  }

  Future<void> _saveData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data.enc');
      final encryptedData = encryptData(jsonEncode(_data));
      await file.writeAsBytes(encryptedData);
      debugPrint("Daten erfolgreich gespeichert.");
    } catch (e) {
      debugPrint("Fehler beim Speichern der Daten: $e");
    }
  }

  void _filterTable(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredData = List.from(_data);
      } else {
        _filteredData = _data.where((row) => row['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  void _showAddPopup() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController userController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    final FocusNode nameFocus = FocusNode();
    final FocusNode userFocus = FocusNode();
    final FocusNode passwordFocus = FocusNode();
    final FocusNode noteFocus = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Neuer Eintrag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  focusNode: nameFocus,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.greenAccent),
                    ),
                  ),
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(userFocus);
                  },
                ),
                TextField(
                  controller: userController,
                  focusNode: userFocus,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Mail/Nutzername',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                    border: UnderlineInputBorder(),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.greenAccent),
                    ),
                  ),
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(passwordFocus);
                  },
                ),
                TextField(
                  controller: passwordController,
                  focusNode: passwordFocus,
                  textInputAction: TextInputAction.next,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Passwort',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                  ),
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(noteFocus);
                  },
                ),
                TextField(
                  controller: noteController,
                  focusNode: noteFocus,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Notizen',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.greenAccent),
                    ),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Abbrechen',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                final newData = {
                  'name': nameController.text,
                  'user': userController.text,
                  'password': passwordController.text,
                  'note': noteController.text,
                  'history': "",
                };
                setState(() {
                  _data.add(newData);
                  _filteredData = List.from(_data);
                });
                _saveData();
                Navigator.of(context).pop();
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  List<int> encryptData(String plainText) {
    final key = encrypt.Key.fromUtf8('a1w63d1a3d1ad8ad43wa3daw34da4dg1'); // 32 signs
    final iv = encrypt.IV.fromLength(16); // 16 Byte IV
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return iv.bytes + encrypted.bytes;
  }

  String decryptData(List<int> encryptedBytes) {
    try {
      final key = encrypt.Key.fromUtf8('a1w63d1a3d1ad8ad43wa3daw34da4dg1'); // 32 signs

      // Extrahiere den IV (erste 16 Bytes) und die verschlüsselten Daten
      final iv = encrypt.IV(Uint8List.fromList(encryptedBytes.sublist(0, 16)));
      final encryptedData = Uint8List.fromList(encryptedBytes.sublist(16));

      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypt.Encrypted(encryptedData);

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print("Fehler beim Entschlüsseln der Daten: $e");
      return jsonEncode([]);
    }
  }

  void _showDeletePopup(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eintrag löschen'),
          content: const Text('Möchten Sie diesen Eintrag wirklich löschen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Abbrechen',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _data.removeAt(index); // Delete list entry
                  _filteredData = List.from(_data);
                });
                _saveData(); // Save changes in data
                Navigator.of(context).pop();
              },
              child: const Text(
                'Löschen',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

/*  Future<void> _loadMasterPassword() async {
    final String? savedPassword = await MasterPasswordManager.loadMasterPassword(context);
    setState(() {
      _masterPassword = savedPassword;
    });
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwörter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPopup,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.settings),
        onPressed: () => _showMasterPasswordPopup(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                labelText: 'Suche',
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterTable, // Tabelle filtern
            ),
            const SizedBox(height: 16),
            Expanded(
                child: ListView.builder(
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                final row = _filteredData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    child: ListTile(
                      title: Text(row['name']),
                      subtitle: Text('${row['user']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: row["password"]),
                              );
                            },
                          ),
                          _data[index]['history'] == ""
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.history,
                                    color: Colors.black45,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Keine Historie vorhanden!"),
                                      ),
                                    );
                                  },
                                )
                              : IconButton(
                                  icon: const Icon(Icons.history),
                                  onPressed: () {
                                    _showHistoryPopup(context, row['history'], index);
                                  },
                                ),
                          _data[index]['note'] == ""
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.edit_note_rounded,
                                    color: Colors.black45,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Keine Notizen vorhanden!"),
                                      ),
                                    );
                                  },
                                )
                              : IconButton(
                                  icon: const Icon(Icons.edit_note_rounded),
                                  onPressed: () {
                                    _showNotesPopup(context, row['note']);
                                  },
                                ),
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () {
                              _showPasswordPopup(context, row['password']);
                            },
                          ),
                        ],
                      ),
                      onLongPress: () {
                        _showOptionsPopup(context, index);
                      },
                    ),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }


  Future<void> _saveMasterPassword(String masterPassword) async {
    await MasterPasswordManager.saveMasterPassword(masterPassword);
    /*setState(() {
      _masterPassword = masterPassword;
    });*/
    context.read<MasterPasswordProvider>().updateMasterPassword(masterPassword);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Neues Master-Passwort gespeichert!"),
      ),
    );
  }

  void _showMasterPasswordPopup() {
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
                Navigator.of(context).pop();
              },
              child: const Text(
                'Abbrechen',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text == passwordConfirmController.text) {
                  _saveMasterPassword(passwordController.text);
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

  void _showEditPopup(int index) {
    final TextEditingController nameController = TextEditingController(text: _data[index]['name']);
    final TextEditingController userController = TextEditingController(text: _data[index]['user']);
    final TextEditingController passwordController = TextEditingController(text: _data[index]['password']);
    final TextEditingController noteController = TextEditingController(text: _data[index]['note']);
    final TextEditingController historyController = TextEditingController(text: _data[index]['history']);

    final FocusNode nameFocus = FocusNode();
    final FocusNode userFocus = FocusNode();
    final FocusNode passwordFocus = FocusNode();
    final FocusNode noteFocus = FocusNode();
    final FocusNode historyFocus = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eintrag bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  focusNode: nameFocus,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                  ),
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(userFocus),
                ),
                TextField(
                  controller: userController,
                  focusNode: userFocus,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Benutzername',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                  ),
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(noteFocus),
                ),
                TextField(
                  controller: passwordController,
                  focusNode: passwordFocus,
                  textInputAction: TextInputAction.done,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Passwort',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                  ),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
                TextField(
                  controller: noteController,
                  focusNode: noteFocus,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'Notizen',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                  ),
                  minLines: 3,
                  maxLines: null,
                ),
                TextField(
                  controller: historyController,
                  focusNode: historyFocus,
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Historie',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Abbrechen',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_data[index]['password'] == passwordController.text) {
                  setState(() {
                    _data[index] = {'name': nameController.text, 'user': userController.text, 'password': passwordController.text, 'note': noteController.text, 'history': historyController.text};
                    _filteredData = List.from(_data);
                  });
                } else {
                  setState(() {
                    _data[index] = {
                      'name': nameController.text,
                      'user': userController.text,
                      'password': passwordController.text,
                      'note': noteController.text,
                      'history': "${historyController.text}\n${_data[index]['password']}"
                    };
                    _filteredData = List.from(_data);
                  });
                }
                _saveData();
                Navigator.of(context).pop();
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsPopup(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Bearbeiten'),
              onTap: () {
                Navigator.of(context).pop();
                _showEditPopup(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Löschen'),
              onTap: () {
                Navigator.of(context).pop();
                _showDeletePopup(context, index);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPasswordPopup(BuildContext context, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Passwort:',
            style: TextStyle(fontSize: 15),
          ),
          content: GestureDetector(
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(text: password),
              );
            },
            child: Text(
              password,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showNotesPopup(BuildContext context, String notes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Notizen:',
            style: TextStyle(fontSize: 15),
          ),
          content: GestureDetector(
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(text: notes),
              );
            },
            child: Text(
              notes,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showHistoryPopup(BuildContext context, String history, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historie:',
                style: TextStyle(fontSize: 15),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Löschung"),
                          content: Text("Historie unwiederruflich löschen?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text('Abbruch'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _data[index]['history'] = "";
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  _saveData();
                                });
                              },
                              child: const Text(
                                'LÖSCHEN',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      });
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            history,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

