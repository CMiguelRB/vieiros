import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vieiros/main/home.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/resources/CustomColors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  String? path = _prefs.getString('currentTrack');
  LoadedTrack loadedTrack = await LoadedTrack().loadTrack(path);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: CustomColors.background,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark
  ));
  runApp(MyApp(_prefs, loadedTrack));
}
class MyApp extends StatelessWidget {
  final SharedPreferences _prefs;
  final LoadedTrack _loadedTrack;
  MyApp(this._prefs, this._loadedTrack);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vieiros',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        backgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: CustomColors.accent
          )
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.white,
            backgroundColor: CustomColors.accent,
            elevation: 2
        ),
        indicatorColor: CustomColors.accent,
        buttonTheme: ButtonThemeData(
          buttonColor: CustomColors.accent,         //  <-- light color
          textTheme: ButtonTextTheme.primary, //  <-- dark text for light background
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedIconTheme: IconThemeData(
                color: CustomColors.accent
            )
        ),
        // Define the default font family.
        fontFamily: 'Lato',
        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, fontFamily: 'Rubik', color: Colors.black87),
          bodyText1: TextStyle(fontSize: 14.0, fontFamily: 'Lato', color: Colors.black87),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Home(prefs: _prefs, loadedTrack: _loadedTrack)
    );
  }
}