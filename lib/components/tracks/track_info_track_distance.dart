import 'package:flutter/material.dart';
import 'package:vieiros/components/info/distance_widget.dart';
import 'package:vieiros/resources/custom_colors.dart';

class TrackInfoTrackDistance extends StatelessWidget {
  final int distance;
  final bool lightMode;

  const TrackInfoTrackDistance({Key? key, required this.distance, required this.lightMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Card(
        elevation: 0,
        color: lightMode ? CustomColors.faintedFaintedAccent : CustomColors.trackBackgroundDark,
        child: (Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: DistanceWidget(
              lightMode: lightMode,
              distance: (distance / 1000).toStringAsFixed(2),
              distanceUnit: 'Km',
              width: width - 60,
            ))));
  }
}
