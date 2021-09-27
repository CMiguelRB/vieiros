import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class VieirosSwitch extends StatelessWidget {

  final Function(bool value, BuildContext context) onChanged;
  final bool value;
  final String tag;

  const VieirosSwitch({Key? key, required this.onChanged, required this.value, required this.tag}):super(key: key);

  Color _getTextColor(Set<MaterialState> states, isTrack) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.selected
    };
    if (states.any(interactiveStates.contains)) {
      return isTrack ? CustomColors.faintedAccent : CustomColors.accent;
    }
    return isTrack ? CustomColors.faintedText : CustomColors.background;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 10, top: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: MainAxisSize.max,children:[Text(I18n.translate(tag)),Switch(
        value: value,
        onChanged: (value) => onChanged(value, context),
        thumbColor: MaterialStateColor.resolveWith((states) => _getTextColor(states, false)),
        trackColor: MaterialStateColor.resolveWith((states) => _getTextColor(states, true)),
      )]),
    );
  }


}