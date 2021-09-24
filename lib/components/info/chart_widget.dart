import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:vieiros/model/altitude_point.dart';

class ChartWidget extends StatelessWidget{

  final bool lightMode;
  final List<charts.Series<AltitudePoint, num>> altitudeData;
  final int altitudeMin;
  final String altitude;
  final String distance;
  final Function onChangeSelected;

  ChartWidget({required this.lightMode, required this.altitudeData, required this.altitude, required this.altitudeMin, required this.distance, required this.onChangeSelected});

  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 1,
        child: charts.LineChart(
                altitudeData,
            primaryMeasureAxis:
            charts.NumericAxisSpec(
                renderSpec: !lightMode
                    ? charts.GridlineRendererSpec(
                    labelStyle: new charts
                        .TextStyleSpec(
                      color: charts
                          .MaterialPalette
                          .white,
                    ),
                    lineStyle:
                    charts.LineStyleSpec(
                      color: charts
                          .MaterialPalette
                          .gray
                          .shadeDefault,
                    ))
                    : null,
                tickProviderSpec: charts
                    .StaticNumericTickProviderSpec(
                  <charts.TickSpec<num>>[
                    charts.TickSpec<num>(
                        altitudeMin),
                    charts.TickSpec<
                        num>(((int.parse(altitude ==
                        '-'
                        ? '0'
                        : altitude) -
                        altitudeMin) ~/
                        3.03) +
                        altitudeMin),
                    charts.TickSpec<
                        num>(((int.parse(altitude ==
                        '-'
                        ? '0'
                        : altitude) -
                        altitudeMin) ~/
                        1.51) +
                        altitudeMin.toInt()),
                    charts.TickSpec<num>(
                        int.parse(altitude == '-'
                            ? '0'
                            : altitude)),
                  ],
                )),
            selectionModels: [
              charts.SelectionModelConfig(
                  type:
                  charts.SelectionModelType.info,
                  changedListener:
                      (charts.SelectionModel model) => onChangeSelected(model))
            ],
            domainAxis: charts.NumericAxisSpec(
                renderSpec: !lightMode
                    ? charts.GridlineRendererSpec(
                    labelStyle:
                    new charts.TextStyleSpec(
                      color: charts
                          .MaterialPalette.white,
                    ),
                    lineStyle:
                    charts.LineStyleSpec(
                      color: charts
                          .MaterialPalette
                          .gray
                          .shadeDefault,
                    ))
                    : null,
                tickProviderSpec: charts
                    .StaticNumericTickProviderSpec(
                  <charts.TickSpec<num>>[
                    charts.TickSpec<num>(0),
                    charts.TickSpec<num>(distance
                        .indexOf('.') !=
                        -1
                        ? double.parse(distance) *
                        1000 ~/
                        3.03
                        : double.parse(distance) ~/
                        3.03),
                    charts.TickSpec<num>(distance
                        .indexOf('.') !=
                        -1
                        ? double.parse(distance) *
                        1000 ~/
                        1.51
                        : double.parse(distance) ~/
                        1.51),
                    charts.TickSpec<num>(distance
                        .indexOf('.') !=
                        -1
                        ? double.parse(distance) *
                        1000
                        : int.parse(distance)),
                  ],
                )),
            animate: true));
  }
}