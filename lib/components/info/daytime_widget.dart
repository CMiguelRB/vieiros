import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class DaytimeWidget extends StatelessWidget {
  final bool lightMode;
  final String toSunset;
  final String sunsetTime;

  const DaytimeWidget({super.key, required this.lightMode, required this.toSunset, required this.sunsetTime});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        width: MediaQuery.of(context).size.width / 2,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(I18n.translate('info_daytime'), style: TextStyle(color: lightMode ? CustomColors.subText : CustomColors.subTextDark)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        I18n.translate('info_daytime_left'),
                        style: TextStyle(color: lightMode ? CustomColors.subText : CustomColors.subTextDark, fontSize: 12),
                      ),
                      Text(toSunset, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
                    ]),
                Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        I18n.translate('info_daytime_sunset'),
                        style: TextStyle(color: lightMode ? CustomColors.subText : CustomColors.subTextDark, fontSize: 12),
                      ),
                      Text(sunsetTime, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
                    ])
              ],
            )
          ],
        ));
  }
}
