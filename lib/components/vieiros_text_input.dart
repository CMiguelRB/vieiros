import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class VieirosTextInput extends StatelessWidget{

  final Function onChanged;
  final String hintText;
  final String? initialValue;

  VieirosTextInput({required this.hintText, required this.onChanged, this.initialValue});

  @override
  Widget build(BuildContext context) {
     return TextFormField(
         cursorColor: CustomColors.accent,
         initialValue: initialValue != null ? initialValue : '',
         decoration: InputDecoration(
           filled: true,
           fillColor: CustomColors.subTextDark,
           hintText: I18n.translate('common_name'),
           contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
           counterStyle: TextStyle(color: CustomColors.accent),
           border: OutlineInputBorder(
             borderSide: BorderSide.none,
           ),
         ),
         onChanged: (value) => onChanged(value),
         validator: (text) {
           if (text == null || text.isEmpty) {
             return I18n.translate('common_empty_name');
           }
           return null;
         });
  }

}