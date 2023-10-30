import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vieiros/main/home.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:vieiros/utils/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Future.delayed(const Duration(milliseconds: 250));
  loadStatusBarTheme();
  await Preferences().loadPreferences();
  String? path = Preferences().get('currentTrack');
  String? theme = Preferences().get("dark_mode");
  if (theme == null) Preferences().set('dark_mode', 'system');
  LoadedTrack loadedTrack;
  if(path != null && path == '/loading'){
    loadedTrack = LoadedTrack();
  }else{
    try {
      loadedTrack = await LoadedTrack().loadTrack(path) as LoadedTrack;
    } on Exception {
      loadedTrack = LoadedTrack();
    }
  }
  Preferences().set('current_directory', '');
  runApp(Vieiros(loadedTrack));
}

void loadStatusBarTheme() {
  String? value = Preferences().get("dark_mode");
  bool light;
  switch (value) {
    case 'light':
      light = true;
      break;
    case 'dark':
      light = false;
      break;
    default:
      SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? light = false : light = true;
  }
  if (light) {
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
}

class Vieiros extends StatelessWidget {
  final LoadedTrack _loadedTrack;

  const Vieiros(this._loadedTrack, {super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final provider = Provider.of<ThemeProvider>(context);
        final currentMode = provider.isLightMode;
        final String? currentPrefs = Preferences().get('dark_mode');
        final bool prefsMode;
        switch (currentPrefs) {
          case 'light':
            prefsMode = true;
            break;
          case 'dark':
            prefsMode = false;
            break;
          default:
            SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? prefsMode = false : prefsMode = true;
        }
        if (currentMode != prefsMode) {
          provider.setThemeMode(currentPrefs);
        }
        return MaterialApp(
            title: 'Vieiros',
            themeMode: provider.themeMode,
            theme: Themes.lightTheme,
            darkTheme: Themes.darkTheme,
            debugShowCheckedModeBanner: false,
            home: Home(loadedTrack: _loadedTrack));
      });
}
