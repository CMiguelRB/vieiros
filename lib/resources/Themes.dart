import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vieiros/resources/CustomColors.dart';

class ThemeProvider extends ChangeNotifier{
  ThemeMode themeMode = ThemeMode.light;

  bool get isLightMode => themeMode == ThemeMode.light;

  void setThemeMode(bool value){
    value == true ? themeMode = ThemeMode.dark : themeMode = ThemeMode.light;

    if(!value){
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarColor: CustomColors.background,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark
      ));
    }else{
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarColor: CustomColors.backgroundDark,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light
      ));
    }

    notifyListeners();
  }
}

class Themes{

  static final lightTheme = ThemeData(
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
        ),
      selectedItemColor: CustomColors.accent,
      unselectedItemColor: Colors.black87,
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
  );


  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black87,
    backgroundColor: Colors.black87,
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
        ),
        unselectedIconTheme: IconThemeData(color:Colors.white),
      selectedItemColor: CustomColors.accent,
      unselectedItemColor: Colors.white,
    ),
    // Define the default font family.
    fontFamily: 'Lato',
    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, fontFamily: 'Rubik', color: Colors.white),
      bodyText1: TextStyle(fontSize: 14.0, fontFamily: 'Lato', color: Colors.white),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}