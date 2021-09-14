import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vieiros/resources/CustomColors.dart';
import 'package:vieiros/resources/I18n.dart';
import 'package:vieiros/resources/Themes.dart';


class Settings extends StatefulWidget {
  final SharedPreferences prefs;

  Settings({Key? key, required this.prefs});

  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  bool _darkMode = false;
  bool _voiceAlerts = true;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.prefs.getString("dark_mode") == 'true';
    _voiceAlerts = widget.prefs.getString("voice_alerts") == 'true' || widget.prefs.getString("voice_alerts") == null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onChangeDarkMode(value, context) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.setThemeMode(value);
    setState(() {
      _darkMode = value;
      widget.prefs.setString("dark_mode", value.toString());
    });
  }

  _onChangeVoiceAlerts (value) async{
    /*FlutterTts flutterTts = FlutterTts();
    String lang = Platform.localeName.replaceAll("_", "-");
    await flutterTts.setLanguage(lang);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(0.9);
    if(value){
      if(lang == 'en-US'){
        flutterTts.speak("Voice alerts enabled");
      }else{
        flutterTts.speak("Alertas de voz habilitadas");
      }
    }else{
      if(lang == 'en-US'){
        flutterTts.speak("Voice alerts disabled");
      }else{
        flutterTts.speak("Alertas de voz deshabilitadas");
      }
    }*/
    setState(() {
      _voiceAlerts = value;
      widget.prefs.setString("voice_alerts", value.toString());
    });
  }

  Color _getTextColor(Set<MaterialState> states, isTrack) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.selected
    };
    if (states.any(interactiveStates.contains)) {
      return isTrack ? CustomColors.faintedAccent : CustomColors.accent;
    }
    return isTrack ? CustomColors.faintedText : CustomColors.background;
  }
  
  void _donate() async {
    String url = 'https://www.paypal.com/donate?hosted_button_id=GGNA5HGUATFFQ';
    if(await canLaunch(url)){
      launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Expanded(
            child: Container(
                padding: EdgeInsets.all(10),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: MainAxisSize.max,children:[Text(I18n.translate('settings_dark_mode')),Switch(
                      value: _darkMode,
                      onChanged: (value) => _onChangeDarkMode(value, context),
                      thumbColor: MaterialStateColor.resolveWith((states) => _getTextColor(states, false)),
                      trackColor: MaterialStateColor.resolveWith((states) => _getTextColor(states, true)),
                    )]),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: MainAxisSize.max,children:[Text(I18n.translate('settings_voice_alerts')),Switch(
                      value: _voiceAlerts,
                      onChanged: _onChangeVoiceAlerts,
                      thumbColor: MaterialStateColor.resolveWith((states) => _getTextColor(states, false)),
                      trackColor: MaterialStateColor.resolveWith((states) => _getTextColor(states, true)),
                    )]),
                  ),
                  Spacer(),
                  Container(
                    child: ElevatedButton(

                      onPressed: _donate, child: Text(I18n.translate('settings_donate')),
                    ),
                  ),
                  Spacer()
                ]))),
        Container(
            child: Column(
          children: [
            Image.asset('assets/app_logo.png', scale: 6),
            Container(
              margin: EdgeInsets.only(bottom: 10),
            ),
            Text('Vieiros v1.0.0',
                style: TextStyle(color: CustomColors.faintedText)),
            Container(
              margin: EdgeInsets.only(bottom: 10),
            )
          ],
        ))
      ],
    ));
  }
}
