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
  final StreamController event = new StreamController.broadcast();

  setRecording(willBeRecording) {
    this.isRecording = willBeRecording;
    event.add('recording status');
  }

  void setTop(int top){
    this.altitudeTop = top;
  }

  void setGain(int gain){
    this.altitudeGain = gain;
  }

  void setMin(int min){
    this.altitudeMin = min;
  }

  void addPosition(position) {
    this.positions.add(position);
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
    this.positions.clear();
    this.waypoints.clear();
    this.name = '';
    this.dateTime = null;
    this.isRecording = false;
    this.distance = 0;
    this.altitudeTop = 0;
    this.altitudeMin = 8849;
    this.altitudeGain = 0;
    event.add('cleared');
  }

  Stream get eventListener => event.stream;
}
