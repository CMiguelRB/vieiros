import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class PaceWidget extends StatelessWidget {
  final bool lightMode;
  final String avgPace;
  final String paceUnit;

  const PaceWidget({Key? key, required this.lightMode, required this.avgPace, required this.paceUnit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: MediaQuery.of(context).size.width / 2,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(I18n.translate('info_pace'), style: TextStyle(color: lightMode ? CustomColors.subText : CustomColors.subTextDark)),
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(avgPace, style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                Container(margin: const EdgeInsets.all(2)),
                Text(paceUnit, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))
              ])
        ],
      ),
    );
  }
}
