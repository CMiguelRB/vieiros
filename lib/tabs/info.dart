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
        Flexible(flex: 2,child: Text(currentTrack.getPositions().length.toString())),
        Flexible(flex: 10, child: Center())
      ],
    )
    );
  }
}