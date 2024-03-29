import 'package:flutter/material.dart';
import 'package:vieiros/components/info/vieiros_timer.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/tabs/info.dart';

class TimeWidget extends StatelessWidget {
  final bool lightMode;
  final InfoDisplay slideState;
  final bool isRecording;
  final DateTime? initDatetime;
  final String? totalTime;
  final double width;

  const TimeWidget(
      {super.key,
      required this.lightMode,
      required this.slideState,
      required this.isRecording,
      required this.totalTime,
      required this.initDatetime,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        width: width / 2,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(I18n.translate('info_total_time'), style: TextStyle(color: lightMode ? CustomColors.subText : CustomColors.subTextDark)),
            isRecording && slideState == InfoDisplay.current
                ? TimerWidget(time: initDatetime!.millisecondsSinceEpoch)
                : Text(totalTime!, style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold))
          ],
        ));
  }
}
