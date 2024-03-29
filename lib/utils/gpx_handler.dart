import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/track.dart';

class GpxHandler {
  Gpx createGpx(CurrentTrack currentTrack, String name, {List<Marker>? currentMarkers}) {
    Gpx gpx = Gpx();
    gpx.metadata = Metadata(name: name);
    gpx.creator = 'vieiros';
    if (currentMarkers != null) _setWaypoints(gpx, currentMarkers);
    List<Wpt> wpts = [];
    for (int i = 0; i < currentTrack.positions.length; i++) {
      wpts.add(Wpt(
          lat: currentTrack.positions[i].latitude,
          lon: currentTrack.positions[i].longitude,
          ele: currentTrack.positions[i].altitude,
          time: currentTrack.positions[i].timestamp!));
    }
    List<Trkseg> trksegs = [];
    trksegs.add(Trkseg(trkpts: wpts));
    gpx.trks.add(Trk(name: name, trksegs: trksegs));
    return gpx;
  }

  Gpx _setWaypoints(Gpx gpx, List<Marker> currentMarkers) {
    for (int i = 0; i < currentMarkers.length; i++) {
      gpx.wpts
          .add(Wpt(lat: currentMarkers[i].position.latitude, lon: currentMarkers[i].position.longitude, name: currentMarkers[i].infoWindow.title));
    }
    return gpx;
  }

  List<LatLng> getPointsFromGpx(Track track) {
    Gpx gpx = track.gpx as Gpx;
    List<LatLng> points = [];
    double? lat;
    double? lon;
    for (int i = 0; i < gpx.trks[0].trksegs[0].trkpts.length; i++) {
      lat = gpx.trks[0].trksegs[0].trkpts[i].lat;
      lon = gpx.trks[0].trksegs[0].trkpts[i].lon;
      if (lat == null || lon == null) continue;
      points.add(LatLng(lat, lon));
    }
    return points;
  }

  String reduceGpxFile(String gpxString){
    Gpx gpx = GpxReader().fromString(gpxString);

    List<Wpt> points = gpx.trks.first.trksegs.first.trkpts;
    List<Wpt> reducedPoints = [];
    int reductionFactor = points.length ~/ 500;
    if(reductionFactor > 0){
      for(int i = 0; i < points.length; i = (i + 1 + reductionFactor)){
        reducedPoints.add(points[i]);
      }
      gpx.trks.first.trksegs.first.trkpts = reducedPoints;
    }

    return GpxWriter().asString(gpx, pretty: true);
  }

  GpxHandler._privateConstructor();

  static final GpxHandler _instance = GpxHandler._privateConstructor();

  factory GpxHandler() {
    return _instance;
  }
}
