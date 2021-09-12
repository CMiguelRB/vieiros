import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vieiros/main/home.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/resources/CustomColors.dart';
import 'package:vieiros/resources/Themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  loadStatusBarTheme(_prefs);
  String? path = _prefs.getString('currentTrack');
  LoadedTrack loadedTrack = await LoadedTrack().loadTrack(path);
  runApp(MyApp(_prefs, loadedTrack));
}

void loadStatusBarTheme(prefs){
  if(prefs.getString('dark_mode') == 'true'){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.black87,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light
    ));
  }else{
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: CustomColors.background,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark
    ));
  }
}


class MyApp extends StatelessWidget {
  final SharedPreferences _prefs;
  final LoadedTrack _loadedTrack;
  MyApp(this._prefs, this._loadedTrack);
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    builder: (context, _){
      final provider = Provider.of<ThemeProvider>(context);
      bool darkMode = _prefs.getString("dark_mode") == 'true';
      if(provider.isLightMode && darkMode){
        provider.setThemeMode(darkMode);
      }
      return MaterialApp(
      title: 'Vieiros',
      themeMode: provider.themeMode,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      debugShowCheckedModeBanner: false,
      home: Home(prefs: _prefs, loadedTrack: _loadedTrack)
    );
    }
  );
}