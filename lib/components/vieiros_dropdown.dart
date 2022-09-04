import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class VieirosDropdown extends StatelessWidget {
  final bool lightMode;
  final String value;
  final Function onChanged;
  final List<Map<String, String>> items;

  const VieirosDropdown({Key? key, required this.lightMode, required this.onChanged, required this.value, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: lightMode ? CustomColors.subTextDark : CustomColors.subText,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: DropdownButton(
            value: value,
            onChanged: (value) => onChanged(value),
            underline: Container(
              height: 0,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            elevation: 2,
            focusColor: CustomColors.accent,
            items: items.map((element) {
              return DropdownMenuItem(value: element["value"], child: Text(I18n.translate(element["tag"]!)));
            }).toList()));
  }
}
