import 'package:vieiros/model/position.dart';
import 'package:vieiros/model/waypoint.dart';

class CurrentTrack {
  bool _recording = false;
  final List<RecordedPosition> _positions = [];
  final List<Waypoint> _waypoints = [];
  String _name = '';

  void addPosition(position){
    this._positions.add(position);
  }

  void setName(name){
    this._name = name;
  }

  void setStatus(recording){
    this._recording = recording;
  }

  void addWaypoint(waypoint){
    this._waypoints.add(waypoint);
  }

  List<RecordedPosition> getPositions(){
    return this._positions;
  }

  List<Waypoint> getWaypoints(){
    return this._waypoints;
  }

  bool isRecording(){
    return this._recording;
  }

  void clear(){
    this._positions.clear();
    this._waypoints.clear();
    this._name = '';
    this._recording = false;
  }
}