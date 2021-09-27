import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vieiros/components/vieiros_dropdown.dart';
import 'package:vieiros/components/vieiros_switch.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';

class Settings extends StatefulWidget {
  final SharedPreferences prefs;

  const Settings({Key? key, required this.prefs}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  bool _voiceAlerts = true;
  String? _themeDropdownValue = 'system';

  @override
  void initState() {
    super.initState();
    _themeDropdownValue = widget.prefs.getString('dark_mode');
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
      _themeDropdownValue = value;
      widget.prefs.setString("dark_mode", value);
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
    bool lightMode = Provider.of<ThemeProvider>(context).isLightMode;
    return SafeArea(
        child: Column(
      children: [
        Expanded(
            child: Column(children: [
          Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(left: 10, top: 40),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(I18n.translate('settings_dark_mode')),
                    VieirosDropdown(
                        lightMode: lightMode,
                        items: const [
                          {
                            "value": 'system',
                            "tag": 'settings_dark_mode_item_system'
                          },
                          {
                            "value": 'light',
                            "tag": 'settings_dark_mode_item_light'
                          },
                          {"value": 'dark', "tag": 'settings_dark_mode_item_dark'}
                        ],
                        onChanged: (value) => _onChangeDarkMode(value, context),
                        value: _themeDropdownValue!)
                  ])),
          VieirosSwitch(
              onChanged: _onChangeVoiceAlerts,
              value: _voiceAlerts,
              tag: 'settings_voice_alerts'),
          const Spacer(),
          ElevatedButton(
            onPressed: _donate,
            child: Text(I18n.translate('settings_donate')),
          ),
          const Spacer()
        ])),
        Column(
          children: [
            Image.asset('assets/app_logo.png', scale: 6),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
            ),
            const Text('Vieiros v1.0.0',
                style: TextStyle(color: CustomColors.faintedText)),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
            )
          ],
        )
      ],
    ));
  }
}
