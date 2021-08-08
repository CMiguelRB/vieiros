import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget{

  final String time;

  TimerWidget({Key? key, required this.time});

  _TimerState createState() => _TimerState();
}

class _TimerState extends State<TimerWidget>{

  String _totalTime = '--:--';
  int _baseTime = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    //_baseTime = widget.time;
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTimer());
  _totalTime = widget.time;
  }

  _updateTimer(){
    setState(() {
      int diff = DateTime.now().millisecondsSinceEpoch - 1628300749000;
      _totalTime = Duration(milliseconds: diff).abs().toString().split('.')[0];
      if(_totalTime.split(':')[0].length < 2){
        _totalTime = '0'+_totalTime;
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
   return Container(
     child:
       Text(_totalTime,
           style: TextStyle(
               fontSize: 35,
               fontWeight: FontWeight.bold))
   );
  }
}