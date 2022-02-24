import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Preferences {
  final _fileName = 'preferences';

  String themeCurrent = "";

  setThemeCurrent(String current) {
    themeCurrent = current;
  }

  String getThemeCurrent() {
    return themeCurrent;
  }

  Future<void> set(String key, String value) async {
    if (key == 'dark_mode') {
      setThemeCurrent(value);
    }
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$_fileName.json');
    Map<String, dynamic> prefs;
    if (!await file.exists()) {
      prefs = {};
    } else {
      prefs = json.decode(file.readAsStringSync());
    }
    prefs[key] = value;
    file.writeAsStringSync(json.encode(prefs));
  }

  Future<String?> get(String key) async {
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$_fileName.json');
    if (!await file.exists()) {
      return null;
    }
    Map<String, dynamic> map = json.decode(file.readAsStringSync());
    String? value = map[key];
    if (key == 'dark_mode' && value != null) {
      setThemeCurrent(value);
    }
    return value;
  }

  Future<void> remove(String key) async {
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$_fileName.json');
    Map<String, dynamic> prefs = json.decode(file.readAsStringSync());
    prefs.remove(key);
    file.writeAsStringSync(json.encode(prefs));
  }

  //Singleton pattern. No need to call an instance getter, just instantiate the class Calc calc = Calc();
  Preferences._privateConstructor();

  static final Preferences _instance = Preferences._privateConstructor();

  factory Preferences() {
    return _instance;
  }
}
