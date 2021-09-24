import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class PaceWidget extends StatelessWidget{

  final bool lightMode;
  final String avgPace;
  final String paceUnit;

  PaceWidget({required this.lightMode, required this.avgPace, required this.paceUnit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(I18n.translate('info_pace'),
              style: TextStyle(
                  color: lightMode
                      ? CustomColors.subText
                      : CustomColors.subTextDark)),
          Container(
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(avgPace,
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold)),
                    Container(margin: EdgeInsets.all(2)),
                    Text(paceUnit,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold))
                  ]))
        ],
      ),
      width: MediaQuery.of(context).size.width / 2,
    );
  }
}