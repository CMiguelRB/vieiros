import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class AltitudeWidget extends StatelessWidget{

  final bool lightMode;
  final String altitudeUnit;
  final String altitude;
  final String altitudeCurrent;
  final String altitudeGain;

  const AltitudeWidget({Key? key, required this.lightMode, required this.altitudeUnit, required this.altitude, required this.altitudeGain, required this.altitudeCurrent}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(I18n.translate('info_altitude'),
                style: TextStyle(
                    color: lightMode
                        ? CustomColors.subText
                        : CustomColors.subTextDark)),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
              CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context)
                            .size
                            .width /
                            3,
                        child: Text(
                          I18n.translate(
                              'info_altitude_current'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: lightMode
                                  ? CustomColors.subText
                                  : CustomColors
                                  .subTextDark,
                              fontSize: 12),
                        )),
                    SizedBox(
                        width: MediaQuery.of(context)
                            .size
                            .width /
                            3,
                        child: Text(
                          I18n.translate(
                              'info_altitude_top'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: lightMode
                                  ? CustomColors.subText
                                  : CustomColors
                                  .subTextDark,
                              fontSize: 12),
                        )),
                    SizedBox(
                        width: MediaQuery.of(context)
                            .size
                            .width /
                            3,
                        child: Text(
                          I18n.translate(
                              'info_altitude_gain'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: lightMode
                                  ? CustomColors.subText
                                  : CustomColors
                                  .subTextDark,
                              fontSize: 12),
                        )),
                  ],
                ),
                Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 3)),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context)
                            .size
                            .width /
                            3,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.baseline,
                          textBaseline:
                          TextBaseline.alphabetic,
                          children: [
                            Text(altitudeCurrent,
                                style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight:
                                    FontWeight.bold)),
                            Text(
                                altitudeCurrent != '-'
                                    ? altitudeUnit
                                    : '',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.bold))
                          ],
                        )),
                    SizedBox(
                        width: MediaQuery.of(context)
                            .size
                            .width /
                            3,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.baseline,
                          textBaseline:
                          TextBaseline.alphabetic,
                          children: [
                            Text(altitude,
                                style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight:
                                    FontWeight.bold)),
                            Text(
                                altitude != '-'
                                    ? altitudeUnit
                                    : '',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.bold))
                          ],
                        )),
                    SizedBox(
                        width: MediaQuery.of(context)
                            .size
                            .width /
                            3,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.baseline,
                          textBaseline:
                          TextBaseline.alphabetic,
                          children: [
                            Text(altitudeGain,
                                style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight:
                                    FontWeight.bold)),
                            Text(
                                altitudeGain != '-'
                                    ? altitudeUnit
                                    : '',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.bold))
                          ],
                        ))
                  ],
                ),
              ],
            )
          ],
        ),
        width: MediaQuery.of(context).size.width);
  }
}