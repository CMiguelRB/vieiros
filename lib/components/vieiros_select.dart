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
      {Key? key,
      required this.lightMode,
      required this.onChanged,
      required this.value,
      required this.titleTag,
      required this.valueTag,
      required this.items,
      required this.context})
      : super(key: key);

  Future<void> _themeSelector() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(I18n.translate('settings_dark_mode')),
              contentPadding: const EdgeInsets.only(top: 10),
              actions: [
                TextButton(
                  child: Text(
                    I18n.translate('common_cancel'),
                    style: const TextStyle(
                        color: CustomColors.accent, fontSize: 15),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              content: SingleChildScrollView(
                  child: ListBody(
                      children: items.map((element) {
                return ListTile(
                  onTap: () => _onElementPressed(element),
                  contentPadding: const EdgeInsets.only(left: 20),
                    title: Text(I18n.translate(element['tag']!)),
                    leading: Radio(
                        value: element['value']!,
                        groupValue: value,
                        activeColor:  CustomColors.accent,
                        onChanged: (value) => _onElementPressed(element)));
              }).toList())));
        });
  }

  _onElementPressed(element) {
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
                  Text(I18n.translate(titleTag),
                      style: const TextStyle(fontSize: 15)),
                  Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(I18n.translate(valueTag),
                          style: TextStyle(
                              fontSize: 13,
                              color: lightMode
                                  ? CustomColors.subText
                                  : CustomColors.subTextDark)))
                ])));
  }
}
