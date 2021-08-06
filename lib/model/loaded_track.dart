import 'dart:io';
import 'package:xml/xml.dart';
import 'package:gpx/gpx.dart';

class LoadedTrack {
  String? path;
  String? gpxString;
  Gpx? gpx;

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

    return this;
  }

  clear(){
    path = null;
    gpxString = null;
    gpx = null;
  }

  LoadedTrack();
}