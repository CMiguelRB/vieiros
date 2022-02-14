import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class VieirosTextInput extends StatelessWidget {
  final Function onChanged;
  final String hintText;
  final String? initialValue;
  final Widget? suffix;
  final TextEditingController? controller;
  final bool lightMode;

  const VieirosTextInput({
    Key? key,
    required this.hintText,
    required this.onChanged,
    required this.lightMode,
    this.initialValue,
    this.suffix,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        autofocus: false,
        cursorColor: CustomColors.accent,
        initialValue: initialValue,
        controller: controller,
        decoration: InputDecoration(
            suffixIcon: suffix,
            filled: true,
            fillColor: lightMode ? CustomColors.subTextDark : CustomColors.subText,
            hintText: I18n.translate(hintText),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            counterStyle: const TextStyle(color: CustomColors.accent),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: CustomColors.subTextDark)),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.accent),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.error),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.error),
            )),
        onChanged: (value) => onChanged(value),
        validator: (text) {
          if (text == null || text.isEmpty) {
            return I18n.translate('common_empty_name');
          }
          return null;
        });
  }
}
