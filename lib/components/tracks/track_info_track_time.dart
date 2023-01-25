import 'package:flutter/material.dart';
import 'package:vieiros/components/info/time_widget.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/tabs/info.dart';

class TrackInfoTrackTime extends StatelessWidget {
  final bool lightMode;
  final String? totalTime;
  final DateTime? initTime;

  const TrackInfoTrackTime({Key? key, required this.totalTime, required this.initTime, required this.lightMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Card(
        elevation: 0,
        color: lightMode ? CustomColors.faintedFaintedAccent : CustomColors.trackBackgroundDark,
        child: (Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: TimeWidget(
              lightMode: lightMode,
              slideState: InfoDisplay.current,
              isRecording: false,
              totalTime: totalTime,
              initDatetime: initTime,
              width: width - 60,
            ))));
  }
}
