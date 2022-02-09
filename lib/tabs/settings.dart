import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vieiros/components/vieiros_select.dart';
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
  String? _themeSelectValue = 'system';
  String? _themeSelectTag = '';
  final List<Map<String, String>> _themes = [
    {
      "value": 'system',
      "tag": 'settings_dark_mode_item_system'
    },
    {
      "value": 'light',
      "tag": 'settings_dark_mode_item_light'
    },
    {
      "value": 'dark',
      "tag": 'settings_dark_mode_item_dark'
    }
  ];

  @override
  void initState() {
    super.initState();
    _themeSelectValue = widget.prefs.getString('dark_mode');
    for(int i = 0; i<_themes.length; i++){
      if(_themes[i]['value'] == _themeSelectValue){
        _themeSelectTag = _themes[i]['tag'];
      }
    }
    _voiceAlerts = widget.prefs.getString("voice_alerts") == 'true' ||
        widget.prefs.getString("voice_alerts") == null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onChangeDarkMode(Map<String, String> element, context) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.setThemeMode(element['value']);
    setState(() {
      _themeSelectValue = element['value'];
      widget.prefs.setString("dark_mode", element['value']!);
      _themeSelectTag = element['tag'];
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
              Container(alignment: Alignment.centerLeft, margin: const EdgeInsets.only(top: 40, left: 20), child: Text(I18n.translate('settings_title'), style: const TextStyle(fontSize: 25),)),
          Column(children: [
            Container(
                margin: const EdgeInsets.only(left: 20, top: 40),
                alignment: Alignment.centerLeft,
                child: Text(I18n.translate('settings_appearance'),
                    style:
                        const TextStyle(fontSize: 14, color: CustomColors.accent))),
            Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(left: 10, top: 5),
                child:
                      VieirosSelect(lightMode: lightMode,
                          onChanged: (element) => _onChangeDarkMode(element, context),
                          titleTag: 'settings_dark_mode',
                          valueTag: _themeSelectTag!,
                          value: _themeSelectValue!,
                          items: _themes, context: context)
                    )
          ]),
          Column(children: [
            Container(
                margin: const EdgeInsets.only(left: 20, top: 40),
                alignment: Alignment.centerLeft,
                child: Text(I18n.translate('settings_alerts'),
                    style:
                        const TextStyle(fontSize: 14, color: CustomColors.accent))),
            VieirosSwitch(
                lightMode: lightMode,
                onChanged: _onChangeVoiceAlerts,
                value: _voiceAlerts,
                titleTag: 'settings_voice_alerts',
                descTag: 'settings_voice_alerts_desc')
          ]),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const StadiumBorder(), elevation: 0),
            onPressed: _donate,
            child: Row( mainAxisSize: MainAxisSize.min, children:  [Container(margin: const EdgeInsets.only(right: 10) ,child: const Icon(Icons.euro)), Text(I18n.translate('settings_donate'))]),
          ),
          const Spacer()
        ])),
        Column(
          children: [
            //Image.asset('assets/app_logo.png', scale: 6),
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
