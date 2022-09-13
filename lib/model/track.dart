import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/utils/calc.dart';
import 'package:vieiros/model/altitude_point.dart';
import 'package:vieiros/utils/files_handler.dart';

class Track {
  String? path;
  String? gpxString;
  Gpx? gpx;

  String name = '';
  int distance = 0;
  int altitudeTop = 0;
  int altitudeMin = 8849;
  int altitudeGain = 0;
  List<AltitudePoint> altitudePoints = [];

  Future<Track> loadTrack(path) async {
    this.path = path;

    if (path == null || path.isEmpty) {
      clear();
      return this;
    }

    try {
      final xmlFile = File(path);
      final String gpxString = await FilesHandler().readAsStringAsync(xmlFile);
      this.gpxString = gpxString;
      gpx = GpxReader().fromString(gpxString);
      String? name = gpx!.trks[0].name;
      name ??= xmlFile.path.split('/')[(xmlFile.path.split('/').length - 1)].split('.gpx')[0];
      this.name = name;
    } on Exception catch (exception) {
      if (kDebugMode) {
        print(exception);
      }
    }

    if (gpx != null) Calc().loadedTrackValues(this);

    return this;
  }

  void setDistance(int distance) {
    this.distance = distance;
  }

  void setTop(int top) {
    altitudeTop = top;
  }

  void setGain(int gainDiff) {
    altitudeGain = gainDiff;
  }

  void setMin(int min) {
    altitudeMin = min;
  }

  void setAltitudePoint(int distance, double altitude) {
    altitudePoints.add(AltitudePoint(distance, altitude));
  }

  clear() {}

  Track();
}
