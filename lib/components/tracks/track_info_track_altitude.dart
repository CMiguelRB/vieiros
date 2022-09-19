import 'package:flutter/material.dart';
import 'package:vieiros/components/info/altitude_widget.dart';
import 'package:vieiros/resources/custom_colors.dart';

class TrackInfoTrackAltitude extends StatelessWidget {
  final String altitudeTop;
  final String altitudeGain;
  final String altitudeMin;
  final bool lightMode;

  const TrackInfoTrackAltitude({Key? key, required this.lightMode, required this.altitudeTop, required this.altitudeGain, required this.altitudeMin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Card(
        elevation: 0,
        color: lightMode ? CustomColors.faintedFaintedAccent : CustomColors.trackBackgroundDark,
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: AltitudeWidget(
                lightMode: lightMode,
                altitudeUnit: 'm',
                altitude: altitudeTop.toString(),
                altitudeGain: altitudeGain.toString(),
                altitudeCurrent: altitudeMin.toString(),
                width: width - 40,
                isAltitudeMin: true)));
  }
}
