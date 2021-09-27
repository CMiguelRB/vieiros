import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';

class GpxHandler {
  
  Gpx createGpx(CurrentTrack currentTrack, String name, {List<Marker>? currentMarkers}){
    Gpx gpx = Gpx();
    gpx.metadata = Metadata(name: name);
    gpx.creator = 'vieiros';
    if(currentMarkers != null) _setWaypoints(gpx, currentMarkers);
    List<Wpt> wpts = [];
    for (var element in currentTrack.positions) {
      wpts.add(Wpt(
          lat: element.latitude,
          lon: element.longitude,
          ele: element.altitude,
          time:
          DateTime.fromMillisecondsSinceEpoch(element.timestamp!.round())));
    }
    List<Trkseg> trksegs = [];
    trksegs.add(Trkseg(trkpts: wpts));
    gpx.trks.add(Trk(name: name, trksegs: trksegs));
    return gpx;
  }

  Gpx _setWaypoints(Gpx gpx, List<Marker> currentMarkers) {
    for (var element in currentMarkers) {
      gpx.wpts.add(Wpt(
          lat: element.position.latitude,
          lon: element.position.longitude,
          name: element.infoWindow.title));
    }
    return gpx;
  }
  
  List<LatLng> getPointsFromGpx(LoadedTrack loadedTrack){
    Gpx gpx = loadedTrack.gpx as Gpx;
    List<LatLng> points = [];
    double? lat;
    double? lon;
    for (var i = 0; i < gpx.trks[0].trksegs[0].trkpts.length; i++) {
      lat = gpx.trks[0].trksegs[0].trkpts[i].lat;
      lon = gpx.trks[0].trksegs[0].trkpts[i].lon;
      if (lat == null || lon == null) continue;
      points.add(LatLng(lat, lon));
    }
    return points;
  }

  GpxHandler._privateConstructor();

  static final GpxHandler _instance = GpxHandler._privateConstructor();

  factory GpxHandler(){
    return _instance;
  }
}