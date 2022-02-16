import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:vieiros/resources/custom_colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  bool get isLightMode => themeMode == ThemeMode.light;

  void setThemeMode(String? value) {
    switch (value) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        SchedulerBinding.instance!.window.platformBrightness == Brightness.dark
            ? themeMode = ThemeMode.dark
            : themeMode = ThemeMode.light;
    }

    if (themeMode == ThemeMode.light) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: CustomColors.background,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarColor: CustomColors.background,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark));
    } else {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: CustomColors.backgroundDark,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarColor: CustomColors.backgroundDark,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light));
    }

    notifyListeners();
  }
}

class Themes {
  static final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: CustomColors.background,
      backgroundColor: CustomColors.background,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(primary: CustomColors.accent)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
          backgroundColor: CustomColors.accent,
          elevation: 2),
      indicatorColor: CustomColors.accent,
      buttonTheme: const ButtonThemeData(
        buttonColor: CustomColors.accent,
        textTheme: ButtonTextTheme.primary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedIconTheme: IconThemeData(color: CustomColors.accent),
        selectedItemColor: CustomColors.accent,
        unselectedItemColor: Colors.black87,
      ),
      fontFamily: 'Lato',
      textTheme: const TextTheme(
        headline1: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
            color: Colors.black87),
        bodyText1: TextStyle(
            fontSize: 14.0, fontFamily: 'Lato', color: Colors.black87),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      dialogTheme: const DialogTheme(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)))
      ),
      snackBarTheme:
          const SnackBarThemeData(contentTextStyle: TextStyle(color:CustomColors.background)));

  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: CustomColors.backgroundDark,
      backgroundColor: CustomColors.backgroundDark,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(primary: CustomColors.accent)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
          backgroundColor: CustomColors.accent,
          elevation: 2),
      indicatorColor: CustomColors.accent,
      buttonTheme: const ButtonThemeData(
        buttonColor: CustomColors.accent,
        textTheme: ButtonTextTheme.primary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedIconTheme: IconThemeData(color: CustomColors.accent),
        unselectedIconTheme: IconThemeData(color: Colors.white),
        selectedItemColor: CustomColors.accent,
        unselectedItemColor: Colors.white,
      ),
      fontFamily: 'Lato',
      textTheme: const TextTheme(
        headline1: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
            color: Colors.white),
        bodyText1:
            TextStyle(fontSize: 14.0, fontFamily: 'Lato', color: Colors.white),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
      snackBarTheme:
          const SnackBarThemeData(contentTextStyle: TextStyle(color:CustomColors.background)));
}
