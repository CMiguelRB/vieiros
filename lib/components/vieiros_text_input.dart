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
  final FocusNode? focusNode;

  const VieirosTextInput(
      {Key? key,
      required this.hintText,
      required this.onChanged,
      required this.lightMode,
      this.initialValue,
      this.suffix,
      this.controller,
      this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        autofocus: false,
        focusNode: focusNode,
        cursorColor: CustomColors.accent,
        initialValue: initialValue,
        controller: controller,
        decoration: InputDecoration(
            suffixIcon: suffix,
            filled: true,
            fillColor: lightMode ? CustomColors.faintedFaintedAccent : CustomColors.subText,
            hintText: I18n.translate(hintText),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            counterStyle: const TextStyle(color: CustomColors.accent),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide(color: CustomColors.subTextDark)),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              borderSide: BorderSide(color: CustomColors.accent),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              borderSide: BorderSide(color: CustomColors.error),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
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
