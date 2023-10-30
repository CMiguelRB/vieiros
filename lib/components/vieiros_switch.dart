import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class VieirosSwitch extends StatelessWidget {
  final Function(bool value, BuildContext context) onChanged;
  final bool value;
  final String titleTag;
  final String? descTag;
  final bool lightMode;

  const VieirosSwitch({super.key, required this.onChanged, required this.value, required this.titleTag, required this.lightMode, this.descTag});

  Color _getTextColor(Set<MaterialState> states, isTrack) {
    const Set<MaterialState> interactiveStates = <MaterialState>{MaterialState.pressed, MaterialState.selected};
    if (states.any(interactiveStates.contains)) {
      return isTrack ? CustomColors.faintedAccent : CustomColors.accent;
    }
    return isTrack ? CustomColors.faintedText : CustomColors.background;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: MainAxisSize.max, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(I18n.translate(titleTag), style: const TextStyle(fontSize: 16)),
          descTag != null
              ? Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(I18n.translate(descTag!),
                      style: TextStyle(fontSize: 13, color: lightMode ? CustomColors.subText : CustomColors.subTextDark)))
              : const Text('')
        ]),
        Switch(
          value: value,
          onChanged: (value) => onChanged(value, context),
          thumbColor: MaterialStateColor.resolveWith((states) => _getTextColor(states, false)),
          trackColor: MaterialStateColor.resolveWith((states) => _getTextColor(states, true)),
        )
      ]),
    );
  }
}
