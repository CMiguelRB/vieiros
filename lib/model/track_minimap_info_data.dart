import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackMiniMapInfoData {
  Set<Marker> markers;
  Set<Polyline> polyline;
  double centerLat;
  double centerLon;

  TrackMiniMapInfoData({required this.markers, required this.polyline, required this.centerLat, required this.centerLon});
}
