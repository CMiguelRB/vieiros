import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class DistanceWidget extends StatelessWidget{

  final bool lightMode;
  final String distance;
  final String distanceUnit;

  DistanceWidget({required this.lightMode, required this.distance, required this.distanceUnit});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(I18n.translate('info_total_distance'),
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
                      Text(distance,
                          style: TextStyle(
                              fontSize: 35,
                              fontWeight:
                              FontWeight.bold)),
                      Container(
                          margin: EdgeInsets.all(2)),
                      Text(distanceUnit,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.bold))
                    ]),
                alignment: Alignment.center)
          ],
        ),
        width: MediaQuery.of(context).size.width / 2,
        alignment: Alignment.center);
  }

}