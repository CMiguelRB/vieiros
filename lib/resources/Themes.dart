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
        SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? themeMode = ThemeMode.dark : themeMode = ThemeMode.light;
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
      useMaterial3: true,
      colorScheme: const ColorScheme(
          error: CustomColors.error,
          brightness: Brightness.light,
          onPrimary: CustomColors.faintedAccent,
          onPrimaryContainer: CustomColors.faintedAccent,
          onSecondary: CustomColors.faintedAccent,
          onSecondaryContainer: CustomColors.faintedFaintedAccent,
          primary: CustomColors.faintedAccent,
          secondary: CustomColors.faintedAccent,
          onError: CustomColors.error,
          surface: Colors.black,
          onSurface: Colors.black
      ),
      elevatedButtonTheme:
          ElevatedButtonThemeData(style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: CustomColors.accent)),
      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(foregroundColor: Colors.white, backgroundColor: CustomColors.accent, elevation: 2),
      scaffoldBackgroundColor: CustomColors.background,
      navigationBarTheme: NavigationBarThemeData(
          surfaceTintColor: CustomColors.background,
          backgroundColor: CustomColors.background,
          indicatorColor: CustomColors.faintedAccent,
          labelTextStyle: WidgetStateProperty.all(const TextStyle(color: CustomColors.backgroundDark)),
          iconTheme: WidgetStateProperty.all(const IconThemeData(color: CustomColors.backgroundDark))),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CustomColors.background,
        selectedLabelStyle: TextStyle(color: CustomColors.backgroundDark),
        unselectedItemColor: CustomColors.backgroundDark,
        selectedItemColor: CustomColors.backgroundDark,
        selectedIconTheme: IconThemeData(color: CustomColors.backgroundDark),
        unselectedIconTheme: IconThemeData(color: CustomColors.backgroundDark),
        showUnselectedLabels: true,
      ),
      fontFamily: 'Lato',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, fontFamily: 'Rubik', color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 14.0, fontFamily: 'Lato', color: Colors.black87),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      dialogTheme: const DialogThemeData(
          backgroundColor: CustomColors.background, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))),
      snackBarTheme: const SnackBarThemeData(contentTextStyle: TextStyle(color: CustomColors.background)),
      segmentedButtonTheme: const SegmentedButtonThemeData(style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 25, vertical: 0)),
        foregroundColor: WidgetStatePropertyAll(Colors.black),
        side: WidgetStatePropertyAll(BorderSide(color: CustomColors.background)),
      )),
      bottomAppBarTheme: const BottomAppBarThemeData(color: CustomColors.background), tabBarTheme: TabBarThemeData(indicatorColor: CustomColors.accent));

  static final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
          error: CustomColors.error,
          brightness: Brightness.dark,
          onPrimary: CustomColors.accent,
          onPrimaryContainer: CustomColors.faintedAccent,
          onSecondary: CustomColors.accent,
          onSecondaryContainer: CustomColors.trackBackgroundDark,
          primary: CustomColors.accent,
          secondary: CustomColors.accent,
          onError: CustomColors.error,
          surface: CustomColors.subTextDark,
          onSurface: CustomColors.subTextDark
      ),
      elevatedButtonTheme:
          ElevatedButtonThemeData(style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: CustomColors.accent)),
      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(foregroundColor: Colors.white, backgroundColor: CustomColors.accent, elevation: 2),
      buttonTheme: const ButtonThemeData(
        buttonColor: CustomColors.accent,
        textTheme: ButtonTextTheme.primary,
      ),
      scaffoldBackgroundColor: CustomColors.backgroundDark,
      navigationBarTheme: NavigationBarThemeData(
          surfaceTintColor: CustomColors.backgroundDark,
          backgroundColor: CustomColors.backgroundDark,
          indicatorColor: CustomColors.faintedAccent,
          labelTextStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            IconThemeData iconThemeData;
            if (states.isNotEmpty && states.first == WidgetState.selected) {
              iconThemeData = const IconThemeData(color: CustomColors.backgroundDark);
            } else {
              iconThemeData = const IconThemeData(color: Colors.white);
            }
            return iconThemeData;
          })),
      fontFamily: 'Lato',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, fontFamily: 'Rubik', color: Colors.white),
        bodyLarge: TextStyle(fontSize: 14.0, fontFamily: 'Lato', color: Colors.white),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      dialogTheme: const DialogThemeData(
          backgroundColor: CustomColors.backgroundDark,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))),
      segmentedButtonTheme: const SegmentedButtonThemeData(style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 25, vertical: 0)),
        foregroundColor: WidgetStatePropertyAll(CustomColors.subTextDark),
        side: WidgetStatePropertyAll(BorderSide(color: CustomColors.backgroundDark)),
      )),
      snackBarTheme: const SnackBarThemeData(contentTextStyle: TextStyle(color: CustomColors.background)), tabBarTheme: TabBarThemeData(indicatorColor: CustomColors.accent));
}
