import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Preferences {
  final _fileName = 'preferences';

  Map<String, dynamic> preferences = {};

  Future<void> loadPreferences() async {
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$_fileName.json');
    if (!await file.exists()) {
      return;
    }
    String str = file.readAsStringSync();
    if(str.isNotEmpty) {
      Map<String, dynamic> map = json.decode(str);
      preferences = map;
    }
  }

  Future<void> set(String key, String value) async {
    preferences[key] = value;
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$_fileName.json');
    file.writeAsString(json.encode(preferences));
  }

  String? get(String key) {
    return preferences[key];
  }

  Future<void> remove(String key) async {
    preferences.remove(key);
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$_fileName.json');
    file.writeAsStringSync(json.encode(preferences));
  }

  //Singleton pattern. No need to call an instance getter, just instantiate the class Calc calc = Calc();
  Preferences._privateConstructor();

  static final Preferences _instance = Preferences._privateConstructor();

  factory Preferences() {
    return _instance;
  }
}
