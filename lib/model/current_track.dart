import 'dart:async';

import 'package:vieiros/model/position.dart';
import 'package:vieiros/model/waypoint.dart';

class CurrentTrack {
  bool isRecording = false;
  DateTime? dateTime;
  final List<RecordedPosition> positions = [];
  final List<Waypoint> waypoints = [];
  String name = '';
  final StreamController event = new StreamController.broadcast();

  setRecording(willBeRecording){
    this.isRecording = willBeRecording;
    event.add('recording status');
  }

  void addPosition(position){
    this.positions.add(position);
    event.add('added position');
  }

  void clear(){
    this.positions.clear();
    this.waypoints.clear();
    this.name = '';
    this.dateTime = null;
    this.isRecording = false;
    event.add('cleared');
  }

  Stream get eventListener => event.stream;
}