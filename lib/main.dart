import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main/home.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark
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
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF0081c6),         //  <-- light color
          textTheme: ButtonTextTheme.primary, //  <-- dark text for light background
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedIconTheme: IconThemeData(
                color: Color(0xFF0081c6)
            )
        ),
        // Define the default font family.
        fontFamily: 'Lato',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          backwardsCompatibility: false,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
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