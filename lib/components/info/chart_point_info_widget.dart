import 'package:flutter/material.dart';
import 'package:vieiros/model/altitude_point.dart';
import 'package:vieiros/resources/i18n.dart';

class ChartPointInfoWidget extends StatelessWidget{

  final AltitudePoint? selectedPoint;

  ChartPointInfoWidget({required this.selectedPoint});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(selectedPoint != null
              ? I18n.translate('info_chart_altitude') +
              ': ' +
              selectedPoint!.altitude
                  .toInt()
                  .toString() +
              ' m.'
              : ''),
          Text(selectedPoint != null
              ? I18n.translate('info_chart_distance') +
              ': ' +
              selectedPoint!.totalDistance
                  .toString() +
              ' m.'
              : ''),
          Container(
            margin: EdgeInsets.only(right: 20),
          )
        ]);
  }
}