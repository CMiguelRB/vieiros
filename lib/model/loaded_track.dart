import 'dart:async';

import 'package:vieiros/model/track.dart';

class LoadedTrack extends Track {
  final StreamController event = StreamController.broadcast();

  @override
  clear() {
    path = null;
    gpxString = null;
    gpx = null;
    distance = 0;
    altitudeTop = 0;
    altitudeGain = 0;
    altitudeMin = 8849;
    altitudePoints = [];
    avgSlope = 0.0;
    event.add('loaded cleared');
  }

  Stream get eventListener => event.stream;

  LoadedTrack();
}
