import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vieiros/components/vieiros_switch.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';

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
    _voiceAlerts = widget.prefs.getString("voice_alerts") == 'true' ||
        widget.prefs.getString("voice_alerts") == null;
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

  _onChangeVoiceAlerts(value, context) async {
    setState(() {
      _voiceAlerts = value;
      widget.prefs.setString("voice_alerts", value.toString());
    });
  }

  void _donate() async {
    String url = 'https://www.paypal.com/donate?hosted_button_id=GGNA5HGUATFFQ';
    if (await canLaunch(url)) {
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
                  VieirosSwitch(
                      onChanged: _onChangeDarkMode,
                      value: _darkMode,
                      tag: 'settings_dark_mode'),
                  VieirosSwitch(
                      onChanged: _onChangeVoiceAlerts,
                      value: _voiceAlerts,
                      tag: 'settings_voice_alerts'),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _donate,
                    child: Text(I18n.translate('settings_donate')),
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
