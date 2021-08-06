import 'package:vieiros/model/position.dart';
import 'package:vieiros/model/waypoint.dart';

class CurrentTrack {
  bool isRecording = false;
  DateTime? dateTime;
  final List<RecordedPosition> positions = [];
  final List<Waypoint> waypoints = [];
  String name = '';

  void clear(){
    this.positions.clear();
    this.waypoints.clear();
    this.name = '';
    this.dateTime = null;
    this.isRecording = false;
  }
}