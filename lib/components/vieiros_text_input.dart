import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class VieirosTextInput extends StatelessWidget {
  final Function onChanged;
  final String hintText;
  final String? initialValue;

  const VieirosTextInput(
      {Key? key,
      required this.hintText,
      required this.onChanged,
      this.initialValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        cursorColor: CustomColors.accent,
        initialValue: initialValue ?? '',
        decoration: InputDecoration(
            filled: true,
            fillColor: CustomColors.subTextDark,
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
