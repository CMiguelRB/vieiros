import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';


class Preferences{

  final _fileName = 'preferences';

  String themeCurrent = "";

  setThemeCurrent(String current){
    themeCurrent = current;
  }

  String getThemeCurrent(){
    return themeCurrent;
  }

  Future<void> set(String key, String value) async {
    if(key == 'dark_mode'){
      setThemeCurrent(value);
    }
    final file = File('${(await getApplicationDocumentsDirectory()).path}/$_fileName.json');
    Map<String, dynamic> prefs;
    if(!await file.exists()){
      prefs = {};
    }else{
      prefs = json.decode(await file.readAsString());
    }
    prefs[key] = value;
    file.writeAsString(json.encode(prefs));
  }

  Future<String?> get(String key) async {
    final file = File('${(await getApplicationDocumentsDirectory()).path}/$_fileName.json');
    if(!await file.exists()){
      return null;
    }
    String? value = json.decode(await file.readAsString())[key];
    if(key == 'dark_mode' && value != null){
      setThemeCurrent(value);
    }
    return value;
  }

  //Singleton pattern. No need to call an instance getter, just instantiate the class Calc calc = Calc();
  Preferences._privateConstructor();

  static final Preferences _instance = Preferences._privateConstructor();

  factory Preferences() {
    return _instance;
  }
}