import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vieiros/model/current_track.dart';


class Info extends StatelessWidget{
  final CurrentTrack currentTrack;

  Info({required this.currentTrack});

  @override
  Widget build(BuildContext context) {

    return SafeArea(child: Column(
      children: [
        Flexible(child: Text(currentTrack.getPositions().length.toString())),
        Icon(Icons.insert_chart_rounded)
      ],
    )
    );
  }
}