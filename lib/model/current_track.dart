import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vieiros/model/position.dart';
import 'package:vieiros/model/waypoint.dart';

class CurrentTrack {
  bool isRecording = false;
  DateTime? dateTime;
  final List<RecordedPosition> positions = [];
  final List<Waypoint> waypoints = [];
  int distance = 0;
  int altitudeTop = 0;
  int altitudeMin = 8849;
  int altitudeGain = 0;
  String name = '';
  final StreamController event = StreamController.broadcast();

  setRecording(willBeRecording) {
    isRecording = willBeRecording;
    event.add('recording status');
  }

  void setTop(int top){
    altitudeTop = top;
  }

  void setGain(int gain){
    altitudeGain = gain;
  }

  void setMin(int min){
    altitudeMin = min;
  }

  void addPosition(position) {
    positions.add(position);
    event.add('added position');
  }

  List<LatLng> getPoints() {
    List<LatLng> _latLngList = [];
    for (var i = 0; i < positions.length; i++) {
      if (positions[i].latitude != null && positions[i].longitude != null) {
        _latLngList.add(LatLng(positions[i].latitude!, positions[i].longitude!));
      }
    }
    return _latLngList;
  }

  void setDistance(int distance) {
    this.distance = distance;
  }

  void clear() {
    positions.clear();
    waypoints.clear();
    name = '';
    dateTime = null;
    isRecording = false;
    distance = 0;
    altitudeTop = 0;
    altitudeMin = 8849;
    altitudeGain = 0;
    event.add('cleared');
  }

  Stream get eventListener => event.stream;
}
