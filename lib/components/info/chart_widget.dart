import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vieiros/model/altitude_point.dart';
import 'package:vieiros/resources/custom_colors.dart';

class ChartWidget extends StatelessWidget {
  final bool lightMode;
  final List<AltitudePoint> altitudeData;
  final int altitudeMin;
  final String altitude;
  final String distance;
  final Color chartColor;
  final Color chartColorFainted;

  const ChartWidget({
    Key? key,
    required this.lightMode,
    required this.chartColor,
    required this.chartColorFainted,
    required this.altitudeData,
    required this.altitude,
    required this.altitudeMin,
    required this.distance,
  }) : super(key: key);

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text = '';
    if (value.toInt() == altitudeMin) {
      text = altitudeMin.toString();
    }
    if (value.toInt().toString() == altitude) {
      text = altitude;
    }

    return Text(text,
        style: const TextStyle(fontSize: 10), textAlign: TextAlign.left);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    String text = '';
    if (value.toInt() == altitudeMin) {
      text = altitudeMin.toString();
    }
    if (value.toInt().toString() == distance) {
      text = distance;
    }

    return Text(text,
        style: const TextStyle(fontSize: 10), textAlign: TextAlign.right);
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat formatter = NumberFormat('###,###,###', 'es_ES');
    return LineChart(LineChartData(
      baselineY: altitudeMin.toDouble(),
      minY: altitudeMin.toDouble(),
      borderData: FlBorderData(
          show: true,
          border: Border(
              bottom: BorderSide(
                  color: lightMode
                      ? CustomColors.subText
                      : CustomColors.subTextDark,
                  width: 0.5))),
      lineTouchData: LineTouchData(
          enabled: true,
          getTouchLineEnd: (barData, spotIndex) => 0,
          getTouchLineStart: (barData, spotIndex) => 0,
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 1.5,
                    strokeColor: chartColor,
                  ),
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
              showOnTopOfTheChartBoxArea: true,
              tooltipMargin: 10,
              tooltipPadding: const EdgeInsets.all(5),
              tooltipBgColor: lightMode
                  ? CustomColors.trackBackgroundLight
                  : CustomColors.trackBackgroundDark,
              fitInsideHorizontally: true,
              getTooltipItems: (List<LineBarSpot> spots) {
                return spots.map((spot) {
                  double d = spot.x;
                  String ds;
                  if (d >= 10000) {
                    ds = (spot.x / 1000)
                            .toString()
                            .padRight(4, '0')
                            .substring(0, 5) +
                        ' Km)';
                  } else {
                    ds = (spot.x / 1000)
                            .toString()
                            .padRight(4, '0')
                            .substring(0, 4) +
                        ' Km)';
                  }
                  return LineTooltipItem(formatter.format(spot.y) + ' m (' + ds,
                      const TextStyle(fontSize: 14));
                }).toList();
              })),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
              color:
                  lightMode ? CustomColors.subText : CustomColors.subTextDark,
              strokeWidth: 0.2);
        },
        horizontalInterval: ((double.parse(altitude != '-' ? altitude : '0') -
                        altitudeMin) /
                    3) >
                0
            ? ((double.parse(altitude != '-' ? altitude : '0') - altitudeMin) /
                3)
            : 1,
        drawVerticalLine: false,
        drawHorizontalLine: true,
      ),
      titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: altitude.length * 11,
                  getTitlesWidget: (value, titleMetaData) {
                    if (value.toInt() == titleMetaData.min.toInt() ||
                        value.toInt() == titleMetaData.max.toInt()) {
                      return Container();
                    }
                    return Text(
                        formatter.format(!value.isNaN ? value.toInt() : ''),
                        style: const TextStyle(fontSize: 10));
                  },
                  interval: ((double.parse(altitude != '-' ? altitude : '0') -
                                  altitudeMin) /
                              3) >
                          0
                      ? ((double.parse(altitude != '-' ? altitude : '0') -
                              altitudeMin) /
                          3)
                      : 1)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 10,
                  getTitlesWidget: (value, titleMetaData) {
                    if (altitudeData.isEmpty || altitudeData.length == 1) {
                      return Container();
                    }
                    try {
                      if (value.isNaN) {
                        return Container();
                      }
                      if (value.toInt() >
                              (double.parse(distance) * 1000 / 3) * 2 &&
                          value.toInt() < titleMetaData.max.toInt()) {
                        return Container();
                      }
                      return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          child: Text(formatter.format(value.toInt()),
                              style: const TextStyle(fontSize: 10)));
                    } catch (e) {
                      return Container();
                    }
                  },
                  interval: double.parse(distance) * 1000 / 3 > 0
                      ? double.parse(distance) * 1000 / 3
                      : 1))),
      lineBarsData: [
        LineChartBarData(
          belowBarData: BarAreaData(
            show: true,
            color: Color.fromARGB(lightMode ? 150 : 20, chartColorFainted.red,
                chartColorFainted.green, chartColorFainted.blue),
          ),
          spots: altitudeData
              .map((e) => FlSpot(
                  e.totalDistance.toDouble(), e.altitude.toInt().toDouble()))
              .toList(),
          color: chartColor,
          isCurved: false,
          barWidth: 1,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
    ));
  }
}
