import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vieiros/main/home.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  loadStatusBarTheme(_prefs);
  String? path = _prefs.getString('currentTrack');
  String? theme = _prefs.getString('dark_mode');
  if(theme == null) _prefs.setString('dark_mode', 'system');
  LoadedTrack loadedTrack = await LoadedTrack().loadTrack(path);
  runApp(MyApp(_prefs, loadedTrack));
}

void loadStatusBarTheme(prefs) {
  String? value = prefs.getString('dark_mode');
  bool light;
  switch(value){
    case 'light':
      light = true;
      break;
    case 'dark':
      light = false;
      break;
    default:
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark ? light = false : light = true;
  }
  if (light) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: CustomColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: CustomColors.background,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark
    ));
  } else {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: CustomColors.backgroundDark,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: CustomColors.backgroundDark,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light
    ));
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences _prefs;
  final LoadedTrack _loadedTrack;

  const MyApp(this._prefs, this._loadedTrack, {Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final provider = Provider.of<ThemeProvider>(context);
        final currentMode = provider.isLightMode;
        final String? currentPrefs = _prefs.getString('dark_mode');
        final bool prefsMode;
        switch(currentPrefs){
          case 'light':
            prefsMode = true;
            break;
          case 'dark':
            prefsMode = false;
            break;
          default:
            SchedulerBinding.instance!.window.platformBrightness == Brightness.dark ? prefsMode = false : prefsMode = true;
        }
        if(currentMode != prefsMode){
          provider.setThemeMode(currentPrefs);
        }
        return MaterialApp(
            title: 'Vieiros',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('es', ''),
              Locale('gl', '')
            ],
            themeMode: provider.themeMode,
            theme: Themes.lightTheme,
            darkTheme: Themes.darkTheme,
            debugShowCheckedModeBanner: false,
            home: Home(prefs: _prefs, loadedTrack: _loadedTrack));
      });
}
