import 'dart:io';
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

  Future<LoadedTrack> loadTrack(path) async {
    this.path = path;

    if (path == null || path.isEmpty){
      this.clear();
      return this;
    }

    final xmlFile = new File(path);
    final String gpxString = XmlDocument.parse(xmlFile.readAsStringSync()).toXmlString();
    this.gpxString = gpxString;
    gpx = GpxReader().fromString(gpxString);

    if(gpx != null) Calc().loadedTrackValues(this);

    return this;
  }

  void setDistance(int distance){
    this.distance = distance;
  }

  void setTop(int top){
    this.altitudeTop = top;
  }

  void setGain(int gainDiff){
    this.altitudeGain = gainDiff;
  }

  void setAltitudePoint(int distance, double altitude){
    this.altitudePoints.add(AltitudePoint(distance, altitude));
  }

  void setMin(int min){
    this.altitudeMin = min;
  }

  clear(){
    this.path = null;
    this.gpxString = null;
    this.gpx = null;
    this.distance = 0;
    this.altitudeTop = 0;
    this.altitudeGain = 0;
    this.altitudeMin = 8849;
    this.altitudePoints = [];
  }

  LoadedTrack();
}