import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/model/track.dart';
import 'package:vieiros/model/current_track.dart';

class Calc {
  void addDistance(CurrentTrack currentTrack) {
    int totalDistance = currentTrack.distance;
    if (currentTrack.positions.length <= 1) return;
    int distance = Geolocator.distanceBetween(
            currentTrack.positions[currentTrack.positions.length - 2].latitude!,
            currentTrack.positions[currentTrack.positions.length - 2].longitude!,
            currentTrack.positions.last.latitude!,
            currentTrack.positions.last.longitude!)
        .round();
    currentTrack.setDistance(totalDistance + distance);
  }

  void setGain(CurrentTrack currentTrack) {
    if (currentTrack.positions.length < 2) return;
    int gain = currentTrack.altitudeGain;
    double gainDiff = currentTrack.positions.last.altitude! - currentTrack.positions[currentTrack.positions.length - 2].altitude!;
    if (gainDiff > 0) gain += gainDiff.round();
    currentTrack.setGain(gain);
  }

  void setTop(CurrentTrack currentTrack) {
    if (currentTrack.positions.last.altitude! > currentTrack.altitudeTop) {
      currentTrack.setTop(currentTrack.positions.last.altitude!.round());
    }
  }

  void setMin(CurrentTrack currentTrack) {
    if (currentTrack.positions.last.altitude! < currentTrack.altitudeMin) {
      currentTrack.setMin(currentTrack.positions.last.altitude!.round());
    }
  }

  double altitudeDiff(CurrentTrack currentTrack) {
    return currentTrack.positions.last.altitude! - currentTrack.positions[currentTrack.positions.length - 2].altitude!;
  }

  double avgPaceSecs(CurrentTrack currentTrack) {
    return DateTime.now().difference(currentTrack.dateTime!).abs().inMilliseconds / 1000 / (currentTrack.distance / 1000);
  }

  String avgPaceMinString(double avgPaceSeconds) {
    String avgPaceMin = (avgPaceSeconds / 60).toStringAsFixed(0);
    avgPaceMin =
        !avgPaceSeconds.isNaN && !avgPaceSeconds.isInfinite && avgPaceSeconds < 3600 ? (avgPaceMin.length > 1 ? avgPaceMin : "0$avgPaceMin") : '00';
    return avgPaceMin;
  }

  String avgPaceSecString(double avgPaceSeconds) {
    String avgPaceSec = (avgPaceSeconds % 60).toStringAsFixed(0);
    avgPaceSec =
        !avgPaceSeconds.isNaN && !avgPaceSeconds.isInfinite && avgPaceSeconds < 3600 ? (avgPaceSec.length > 1 ? avgPaceSec : "0$avgPaceSec") : '00';
    return avgPaceSec;
  }

  String getSunsetTime(double? lat, double? lon, DateTime sunset) {
    if (lat != null && lon != null) {
      return '${sunset.hour}:${sunset.minute.toString().length > 1 ? sunset.minute.toString() : "0${sunset.minute}"}';
    }
    return '--:--';
  }

  String getDaylight(DateTime sunset) {
    int minutesToSunset = sunset.toUtc().difference(DateTime.now().toLocal()).inMinutes - DateTime.now().timeZoneOffset.inMinutes;
    if (minutesToSunset <= 0) return '00:00';
    int toSunsetH = minutesToSunset ~/ 60;
    String toSunsetSH = toSunsetH.toString();
    toSunsetSH = toSunsetSH.length > 1 ? toSunsetSH : '0$toSunsetSH';
    int toSunsetM = minutesToSunset - toSunsetH * 60;
    String toSunsetSM = toSunsetM.toString();
    toSunsetSM = toSunsetSM.length > 1 ? toSunsetSM : '0$toSunsetSM';
    return '$toSunsetSH:$toSunsetSM';
  }

  void loadedTrackValues(Track track) {
    int distance = 0;
    Gpx gpx = track.gpx!;
    List<Wpt> trackPoints = gpx.trks[0].trksegs[0].trkpts;
    for (int i = 0; i < trackPoints.length; i++) {
      if (i > 0) {
        int distanceAux =
            Geolocator.distanceBetween(trackPoints[i - 1].lat!, trackPoints[i - 1].lon!, trackPoints[i].lat!, trackPoints[i].lon!).round();
        distance += distanceAux;
        double gainDiff = trackPoints[i].ele! - trackPoints[i - 1].ele!;
        if (gainDiff > 0) track.setGain(track.altitudeGain + gainDiff.round());
      }
      if (trackPoints[i].ele! > track.altitudeTop) {
        track.setTop(trackPoints[i].ele!.round());
      }
      if (trackPoints[i].ele! < track.altitudeMin) {
        track.setMin(trackPoints[i].ele!.round());
      }
      if (((trackPoints.length > 500 && i % 2 != 0) || (trackPoints.length > 1000 && i % 3 != 0) || (trackPoints.length > 3000 && i % 5 != 0))) {
        continue;
      }
      track.setAltitudePoint(distance, trackPoints[i].ele!);
    }
    track.setDistance(distance);
  }

  Map<String, double> getPolygonCenter({required List<LatLng> points}) {
    double maxX = -90;
    double minX = 90;
    double maxY = -180;
    double minY = 180;
    for (int i = 0; i < points.length; i++) {
      if (points[i].latitude > maxY) {
        maxY = points[i].latitude;
      }
      if (points[i].latitude < minY) {
        minY = points[i].latitude;
      }
      if (points[i].longitude > maxX) {
        maxX = points[i].longitude;
      }
      if (points[i].longitude < minX) {
        minX = points[i].longitude;
      }
    }

    double centerLon = (maxX + minX) / 2;
    double centerLat = (maxY + minY) / 2;

    return {"lat": centerLat, "lon": centerLon};
  }

  //Singleton pattern. No need to call an instance getter, just instantiate the class Calc calc = Calc();
  Calc._privateConstructor();

  static final Calc _instance = Calc._privateConstructor();

  factory Calc() {
    return _instance;
  }
}
