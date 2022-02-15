import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:vieiros/model/altitude_point.dart';
import 'package:vieiros/utils/calc.dart';
import 'package:xml/xml.dart';
import 'package:gpx/gpx.dart';

class LoadedTrack {
  String? path;
  String? gpxString;
  Gpx? gpx;
  int distance = 0;
  int altitudeTop = 0;
  int altitudeMin = 8849;
  int altitudeGain = 0;
  List<AltitudePoint> altitudePoints = [];
  final StreamController event = StreamController.broadcast();

  Future<LoadedTrack> loadTrack(path) async {
    this.path = path;

    if (path == null || path.isEmpty) {
      clear();
      return this;
    }

    try {
      final xmlFile = File(path);
      final String gpxString =
          XmlDocument.parse(xmlFile.readAsStringSync()).toXmlString();
      this.gpxString = gpxString;
      gpx = GpxReader().fromString(gpxString);
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

  void setAltitudePoint(int distance, double altitude) {
    altitudePoints.add(AltitudePoint(distance, altitude));
  }

  void setMin(int min) {
    altitudeMin = min;
  }

  clear() {
    path = null;
    gpxString = null;
    gpx = null;
    distance = 0;
    altitudeTop = 0;
    altitudeGain = 0;
    altitudeMin = 8849;
    altitudePoints = [];
    event.add('loaded cleared');
  }

  Stream get eventListener => event.stream;

  LoadedTrack();
}
