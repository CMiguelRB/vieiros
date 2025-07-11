import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gpx/gpx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vieiros/utils/calc.dart';
import 'package:vieiros/model/altitude_point.dart';
import 'package:vieiros/utils/files_handler.dart';
import 'package:vieiros/utils/gpx_handler.dart';
import 'package:vieiros/utils/preferences.dart';

class Track {
  String? path;
  String? gpxString;
  Gpx? gpx;

  String name = '';
  int distance = 0;
  int altitudeTop = 0;
  int altitudeMin = 8849;
  int altitudeGain = 0;
  double avgSlope = 0.0;
  List<AltitudePoint> altitudePoints = [];

  Future<Track> loadTrack(String? path) async {
    this.path = path;

    if (path == null || path.isEmpty) {
      clear();
      return this;
    }

    try {
      final xmlFile = File(path);
      String? gpxString = await FilesHandler().readAsStringAsync(xmlFile);
      if (gpxString == '') throw Exception('Empty xml string');
      this.gpxString = gpxString;
      if(!path.contains('${(await getApplicationDocumentsDirectory()).path}/tracks/')){
        gpxString = GpxHandler().reduceGpxFile(gpxString);
      }
      gpx = GpxReader().fromString(gpxString);
      String? name = gpx!.trks[0].name;
      name ??= xmlFile.path.split('/')[(xmlFile.path.split('/').length - 1)].split('.gpx')[0];
      Preferences().set(path, name);
      this.name = name;
    } on Exception catch (exception) {
      if (kDebugMode) {
        print(exception);
      }
    }

    if(gpx != null && !path.contains('${(await getApplicationDocumentsDirectory()).path}/tracks/')){
      List<Wpt> points = gpx!.trks.first.trksegs.first.trkpts;
      List<Wpt> reducedPoints = [];
      int reductionFactor = points.length ~/ 500;
      if(reductionFactor > 0){
        for(int i = 0; i < points.length; i = (i + 1 + reductionFactor)){
          reducedPoints.add(points[i]);
        }
        gpx!.trks.first.trksegs.first.trkpts = reducedPoints;
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

  void setAvgSlope(double slope){
    avgSlope = slope;
  }

  void clear() {}

  Track();
}
