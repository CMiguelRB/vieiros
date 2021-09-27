import 'package:geolocator/geolocator.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';

class Calc {

  void addDistance(CurrentTrack currentTrack) {
    int _totalDistance = currentTrack.distance;
    if (currentTrack.positions.length <= 1) return;
    int _distance = Geolocator.distanceBetween(
            currentTrack.positions[currentTrack.positions.length - 2].latitude!,
            currentTrack
                .positions[currentTrack.positions.length - 2].longitude!,
            currentTrack.positions.last.latitude!,
            currentTrack.positions.last.longitude!).round();
    currentTrack.setDistance(_totalDistance + _distance);
  }

  void setGain(CurrentTrack currentTrack) {
    if (currentTrack.positions.length < 2) return;
    int gain = currentTrack.altitudeGain;
    double gainDiff = currentTrack.positions.last.altitude! -
        currentTrack.positions[currentTrack.positions.length - 2].altitude!;
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
    return currentTrack.positions.last.altitude! -
        currentTrack.positions[currentTrack.positions.length - 2].altitude!;
  }

  double avgPaceSecs(CurrentTrack currentTrack) {
    return DateTime.now()
            .difference(currentTrack.dateTime!)
            .abs()
            .inMilliseconds /
        1000 /
        (currentTrack.distance / 1000);
  }

  String avgPaceMinString(double avgPaceSeconds) {
    String avgPaceMin = (avgPaceSeconds / 60).toStringAsFixed(0);
    avgPaceMin = !avgPaceSeconds.isNaN &&
            !avgPaceSeconds.isInfinite &&
            avgPaceSeconds < 3600
        ? (avgPaceMin.length > 1 ? avgPaceMin : "0$avgPaceMin")
        : '00';
    return avgPaceMin;
  }

  String avgPaceSecString(double avgPaceSeconds) {
    String avgPaceSec = (avgPaceSeconds % 60).toStringAsFixed(0);
    avgPaceSec = !avgPaceSeconds.isNaN &&
            !avgPaceSeconds.isInfinite &&
            avgPaceSeconds < 3600
        ? (avgPaceSec.length > 1 ? avgPaceSec : "0$avgPaceSec")
        : '00';
    return avgPaceSec;
  }

  String getSunsetTime(CurrentTrack currentTrack, DateTime sunset) {
    double? lat = currentTrack.positions.last.latitude;
    double? lon = currentTrack.positions.last.longitude;
    if (lat != null && lon != null) {
      return sunset.hour.toString() + ':' + sunset.minute.toString();
    }
    return '--:--';
  }

  String getDaylight(CurrentTrack currentTrack, DateTime sunset) {
    int toSunsetH = (sunset.hour - DateTime.now().hour);
    if(toSunsetH < 0) return '00:00';
    String toSunsetSH = toSunsetH.toString();
    toSunsetSH = toSunsetSH.length > 1 ? toSunsetSH : '0' + toSunsetSH;
    int toSunsetM = (sunset.minute - DateTime.now().minute);
    if(toSunsetM < 0) return '00:00';
    String toSunsetSM = toSunsetM.toString();
    toSunsetSM = toSunsetSM.length > 1 ? toSunsetSM : '0' + toSunsetSM;
    return toSunsetSH + ':' + toSunsetSM;
  }

  void loadedTrackValues(LoadedTrack loadedTrack){
    int distance = 0;
    Gpx gpx = loadedTrack.gpx!;
    List<Wpt> trackPoints = gpx.trks[0].trksegs[0].trkpts;
    for (var i = 0; i < trackPoints.length; i++) {
      if(i > 0){
        int _distance = Geolocator.distanceBetween(
            trackPoints[i-1].lat!,
            trackPoints[i-1].lon!,
            trackPoints[i].lat!,
            trackPoints[i].lon!)
            .round();
        distance += _distance;
        double gainDiff = trackPoints[i].ele! - trackPoints[i-1].ele!;
        if (gainDiff > 0) loadedTrack.setGain(loadedTrack.altitudeGain+gainDiff.round());
      }
      if (trackPoints[i].ele! > loadedTrack.altitudeTop) {
        loadedTrack.setTop(trackPoints[i].ele!.round());
      }
      if(trackPoints[i].ele! < loadedTrack.altitudeMin){
        loadedTrack.setMin(trackPoints[i].ele!.round());
      }
      if (((trackPoints.length > 500 && i % 2 != 0) ||
          (trackPoints.length > 1000 && i % 3 != 0) ||
          (trackPoints.length > 3000 && i % 5 != 0))) {
        continue;
      }
      loadedTrack.setAltitudePoint(distance, trackPoints[i].ele!);
    }
    loadedTrack.setDistance(distance);

  }

  //Singleton pattern. No need to call an instance getter, just instantiate the class Calc calc = Calc();
  Calc._privateConstructor();

  static final Calc _instance = Calc._privateConstructor();

  factory Calc() {
    return _instance;
  }
}
