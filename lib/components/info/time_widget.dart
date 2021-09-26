import 'package:flutter/material.dart';
import 'package:vieiros/components/info/vieiros_timer.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class TimeWidget extends StatelessWidget{

  final bool lightMode;
  final int slideState;
  final bool isRecording;
  final DateTime? initDatetime;
  final String? totalTime;

  const TimeWidget({Key? key, required this.lightMode, required this.slideState, required this.isRecording, required this.totalTime, required this.initDatetime}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(I18n.translate('info_total_time'),
                style: TextStyle(
                    color: lightMode
                        ? CustomColors.subText
                        : CustomColors.subTextDark)),
            isRecording &&
                slideState == 0
                ? TimerWidget(
                time: initDatetime!.millisecondsSinceEpoch)
                : Text(totalTime!,
                style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold))
          ],
        ),
        width: MediaQuery.of(context).size.width / 2,
        alignment: Alignment.center);
  }


}