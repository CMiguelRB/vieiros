import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class VieirosSelect extends StatelessWidget {
  final bool lightMode;
  final String value;
  final Function onChanged;
  final String titleTag;
  final String valueTag;
  final List<Map<String, String>> items;
  final BuildContext context;

  const VieirosSelect(
      {super.key,
      required this.lightMode,
      required this.onChanged,
      required this.value,
      required this.titleTag,
      required this.valueTag,
      required this.items,
      required this.context});

  Future<void> _themeSelector() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              elevation: 2,
              title: Text(I18n.translate('settings_dark_mode')),
              actions: [
                Container(
                    margin: const EdgeInsets.only(right: 24, bottom: 10),
                    child: TextButton(
                      child: Text(
                        I18n.translate('common_cancel'),
                        style: const TextStyle(color: CustomColors.accent, fontSize: 15),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )),
              ],
              content: SingleChildScrollView(
                  child: ListBody(
                      children: items.map((element) {
                return ListTile(
                    onTap: () => _onElementPressed(element),
                    title: Text(I18n.translate(element['tag']!)),
                    leading: Radio(
                        value: element['value']!,
                        groupValue: value,
                        activeColor: CustomColors.accent,
                        onChanged: (value) => _onElementPressed(element)));
              }).toList())));
        });
  }

  void _onElementPressed(Map<String, String> element) {
    onChanged(element);
    Navigator.pop(context, element);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => _themeSelector(),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            alignment: Alignment.centerLeft,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(I18n.translate(titleTag), style: const TextStyle(fontSize: 16)),
                  Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(I18n.translate(valueTag),
                          style: TextStyle(fontSize: 13, color: lightMode ? CustomColors.subText : CustomColors.subTextDark)))
                ])));
  }
}
