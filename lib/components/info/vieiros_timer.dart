import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int time;

  const TimerWidget({Key? key, required this.time}) : super(key: key);

  @override
  TimerState createState() => TimerState();
}

class TimerState extends State<TimerWidget> {
  String _totalTime = '--:--';
  int _baseTime = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _baseTime = widget.time;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTimer());
  }

  _updateTimer() {
    setState(() {
      int diff = DateTime.now().millisecondsSinceEpoch - _baseTime;
      _totalTime = Duration(milliseconds: diff).abs().toString().split('.')[0];
      if (_totalTime.split(':')[0].length < 2) {
        _totalTime = '0$_totalTime';
      }
    });
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_totalTime, style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold));
  }
}
