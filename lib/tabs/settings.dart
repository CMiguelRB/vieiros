import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vieiros/components/vieiros_select.dart';
import 'package:vieiros/components/vieiros_switch.dart';
import 'package:vieiros/model/tp_library.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:vieiros/utils/preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  bool _voiceAlerts = true;
  String? _themeSelectValue = 'system';
  String? _themeSelectTag = '';
  bool tpOpen = false;
  
  List<TPLibrary> thirdParties = [];
  
  final List<Map<String, String>> _themes = [
    {"value": 'system', "tag": 'settings_dark_mode_item_system'},
    {"value": 'light', "tag": 'settings_dark_mode_item_light'},
    {"value": 'dark', "tag": 'settings_dark_mode_item_dark'}
  ];

  @override
  void initState() {
    super.initState();
    _getLicenses();
    if (Preferences().get('dark_mode') != null) {
      _themeSelectValue = Preferences().get('dark_mode');
    }
    setState(() {
      _voiceAlerts = Preferences().get("voice_alerts") == 'true' ||
          Preferences().get("voice_alerts") == null;
      for (int i = 0; i < _themes.length; i++) {
        if (_themes[i]['value'] == _themeSelectValue) {
          _themeSelectTag = _themes[i]['tag'];
        }
      }
    });
  }

  _getLicenses()async{
    List<dynamic> tpJSON = json.decode(await rootBundle.loadString('assets/licenses.json'));
    setState(() {
      for(int i = 0; i<tpJSON.length;i++){
        thirdParties.add(TPLibrary.fromJson(tpJSON[i]));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onChangeDarkMode(Map<String, String> element, context) {
    Preferences().set("dark_mode", element['value']!);
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.setThemeMode(element['value']);
    setState(() {
      _themeSelectValue = element['value'];
      _themeSelectTag = element['tag'];
    });
  }

  _onChangeVoiceAlerts(value, context) {
    setState(() {
      _voiceAlerts = value;
      Preferences().set("voice_alerts", value.toString());
    });
  }

  closeTp() {
    setState(() {
      tpOpen = false;
      for (int i = 0; i < thirdParties.length; i++) {
        thirdParties.toList().elementAt(i).setExpanded(true);
      }
      Navigator.pop(context);
    });
  }

  _show(bool lightMode) {
    setState(() {
      tpOpen = true;
    });
    showBottomSheet(
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                  color: lightMode
                      ? CustomColors.background
                      : CustomColors.backgroundDark,
                  alignment: Alignment.bottomCenter,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(
                                top: 80, left: 24, right: 24, bottom: 20),
                            child: Text(
                              I18n.translate('settings_third_party_thanks'),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                        Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.all(8),
                                itemCount: thirdParties.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return
                                    ExpansionTile(
                                        collapsedBackgroundColor: lightMode ? CustomColors.background : CustomColors.backgroundDark,
                                        backgroundColor: lightMode ? CustomColors.background : CustomColors.backgroundDark,
                                        iconColor: CustomColors.accent,
                                        textColor: lightMode
                                            ? CustomColors.subText
                                            : CustomColors.subTextDark,
                                        title: Text(
                                          thirdParties
                                              .elementAt(index).title,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        children: [
                                          Container(
                                              color: lightMode
                                                  ? Colors.white
                                                  : CustomColors.backgroundDark,
                                              padding: const EdgeInsets.all(5),
                                              child: Text(
                                                  thirdParties.elementAt(
                                                      index).license,
                                                  textAlign: TextAlign.justify,
                                                  style: const TextStyle(
                                                      fontSize: 8,
                                                      fontFamily: 'monospace')))
                                        ],
                                        onExpansionChanged: (expanded) => {
                                              setState(() {
                                                if (!expanded) {
                                                  thirdParties
                                                          .toList()
                                                          .elementAt(index).setExpanded(true);
                                                } else {
                                                  thirdParties
                                                          .toList()
                                                          .elementAt(index).setExpanded(false);
                                                }
                                              })
                                            },
                                  );
                                })),
                        Container(
                            margin: const EdgeInsets.all(10),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder(), elevation: 0),
                                onPressed: closeTp,
                                child: Text(I18n.translate('common_close'))))
                      ]));
            }));
  }

  @override
  Widget build(BuildContext context) {
    bool lightMode = Provider.of<ThemeProvider>(context).isLightMode;
    return SafeArea(
        child: Column(children: [
      Expanded(
          child: Column(children: [
        Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 40, left: 20),
            child: Text(
              I18n.translate('settings_title'),
              style: const TextStyle(fontSize: 25),
            )),
        Column(children: [
          Container(
              margin: const EdgeInsets.only(left: 20, top: 40),
              alignment: Alignment.centerLeft,
              child: Text(I18n.translate('settings_appearance'),
                  style: const TextStyle(
                      fontSize: 14, color: CustomColors.accent))),
          Container(
              margin: const EdgeInsets.only(left: 15, top: 5),
              child: VieirosSelect(
                  lightMode: lightMode,
                  onChanged: (element) => _onChangeDarkMode(element, context),
                  titleTag: 'settings_dark_mode',
                  valueTag: _themeSelectTag!,
                  value: _themeSelectValue!,
                  items: _themes,
                  context: context))
        ]),
        Column(children: [
          Container(
              margin: const EdgeInsets.only(left: 20, top: 30),
              alignment: Alignment.centerLeft,
              child: Text(I18n.translate('settings_alerts'),
                  style: const TextStyle(
                      fontSize: 14, color: CustomColors.accent))),
          VieirosSwitch(
              lightMode: lightMode,
              onChanged: _onChangeVoiceAlerts,
              value: _voiceAlerts,
              titleTag: 'settings_voice_alerts',
              descTag: 'settings_voice_alerts_desc')
        ]),
        const Spacer()
      ])),
      Column(
        children: [
          //Image.asset('assets/app_logo.png', scale: 6),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
          ),
          TextButton(
              onPressed: () => _show(lightMode),
              child: const Text('Vieiros v1.0.4',
                  style: TextStyle(color: CustomColors.faintedText))),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
          )
        ],
      ),
    ]));
  }
}
