import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vieiros/model/position.dart';
import 'package:vieiros/model/waypoint.dart';
import 'package:vieiros/model/track.dart';

class CurrentTrack extends Track {
  bool isRecording = false;
  DateTime? dateTime;
  final List<RecordedPosition> positions = [];
  final List<Waypoint> waypoints = [];
  final StreamController event = StreamController.broadcast();

  setRecording(willBeRecording) {
    isRecording = willBeRecording;
    event.add('recording status');
  }

  void addPosition(position) {
    positions.add(position);
    event.add('added position');
  }

  List<LatLng> getPoints() {
    List<LatLng> latLngList = [];
    for (int i = 0; i < positions.length; i++) {
      if (positions[i].latitude != null && positions[i].longitude != null) {
        latLngList.add(LatLng(positions[i].latitude!, positions[i].longitude!));
      }
    }
    return latLngList;
  }

  @override
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
