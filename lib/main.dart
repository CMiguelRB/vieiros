import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vieiros/main/home.dart';
import 'package:vieiros/resources/CustomColors.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vieiros',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
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
      home: Home()
    );
  }
}