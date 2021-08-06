import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/gpx_file.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/model/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/resources/CustomColors.dart';

class Map extends StatefulWidget {
  final Function setPlayIcon;
  final CurrentTrack currentTrack;
  final LoadedTrack loadedTrack;
  final SharedPreferences prefs;
  Map({Key? key, required this.setPlayIcon, required this.prefs, required this.currentTrack, required this.loadedTrack}) : super(key: key);
  MapState createState() => MapState();
}

class MapState extends State<Map> with AutomaticKeepAliveClientMixin{
  Location _location = new Location();
  Completer<GoogleMapController> _mapController = Completer();
  Set<Polyline> _polyline = Set();
  Set<Marker> _markers = Set();
  final _formKey = GlobalKey<FormState>();
  String currentPath = '';

  getLocation() async {
    await _handlePermissions();
    Future.delayed(const Duration(milliseconds: 500), () {
      if(this.mounted) setState(() {
        showMap = true;
      });
    });
    _location.changeNotificationOptions(iconName: 'vieiros_logo_notification',color: CustomColors.accent, onTapBringToFront: true, title: 'Recording track', description: 'Vieiros is tracking your position');
    _location.changeSettings(interval: 10000, distanceFilter: 5);
    LocationData _locationData;
    final GoogleMapController controller = await _mapController.future;

    _locationData = await _location.getLocation();
    double? lat = _locationData.latitude;
    double? lon = _locationData.longitude;
    if(lat != null && lon != null){
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(lat, lon), zoom: 15.0)));
    }
  }

  _handlePermissions() async{
    bool hasPermission = await permission_handler.Permission.location.isGranted;
    if(!hasPermission){
      final status = await permission_handler.Permission.locationAlways.request();
      if(status == permission_handler.PermissionStatus.granted){
        return true;
      }else{
        return false;
      }
    }
    return true;
  }

  addMarkerSet(LatLng latLng, bool isWayPoint, String? description, GoogleMapController controller) async{
    BitmapDescriptor icon;
    if(!isWayPoint){
      icon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(100, 100)), 'assets/pin.png');
    }else{
      icon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(100, 100)), 'assets/flag.png');
    }
    MarkerId markerId = MarkerId(Uuid().v4());
    Marker marker;
    if(description != null && description.isNotEmpty){
      marker = Marker(markerId: markerId, position: latLng, icon: icon, infoWindow: InfoWindow(title: description), onTap: () => controller.showMarkerInfoWindow(markerId));
    }else{
      marker = Marker(markerId: markerId, position: latLng, icon: icon);
    }
    if(this.mounted) setState(() {
      _markers.add(marker);
    });
  }

  loadTrack(path) async{
    await widget.loadedTrack.loadTrack(path);
    loadCurrentTrack();
  }

  clearTrack(){
    if(this.mounted) setState(() {
      _polyline.clear();
      _markers.clear();
    });
  }

  loadCurrentTrack() async {
    _polyline.clear();
    _markers.clear();
    final GoogleMapController controller = await _mapController.future;
    if(widget.loadedTrack.gpx != null){
      Gpx gpx = widget.loadedTrack.gpx as Gpx;
      List<LatLng> points = [];
      LatLng first = LatLng(0, 0);
      LatLng last = LatLng(0, 0);
      double? lat;
      double? lon;
      for(var i = 0; i<gpx.trks[0].trksegs[0].trkpts.length; i++){
        lat = gpx.trks[0].trksegs[0].trkpts[i].lat;
        lon = gpx.trks[0].trksegs[0].trkpts[i].lon;
        if(lat == null || lon == null) continue;
        if(i == 0) first = LatLng(lat, lon);
        points.add(LatLng(lat, lon));
      }
      for(var i = 0; i<gpx.wpts.length;i++){
        lat = gpx.wpts[i].lat;
        lon = gpx.wpts[i].lon;
        if(lat == null || lon == null) continue;
        addMarkerSet(LatLng(lat, lon), true, gpx.wpts[i].name, controller);
      }
      if(lat != null && lon != null) last = LatLng(lat, lon);
      Polyline polyline = new Polyline(polylineId: new PolylineId('loadedTrack'), points: points, width: 5, color: CustomColors.accent);
      addMarkerSet(first, false, null, controller);
      addMarkerSet(last, false, null, controller);
      if(this.mounted) setState(() {
        _polyline.add(polyline);
        currentPath = widget.loadedTrack.path as String;
      });
      if(lat == null || lon == null) return;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: first, zoom: 14.0)));
    }
  }

  startRecording(){
    widget.currentTrack.isRecording = true;
    widget.currentTrack.dateTime = DateTime.now();
    _location.enableBackgroundMode(enable: true);
    _location.onLocationChanged.listen((event) {
      if(widget.currentTrack.isRecording){
        double? lat = event.latitude;
        double? lon = event.longitude;
        widget.currentTrack.positions.add(RecordedPosition(lat, lon, event.altitude, event.time));
        List<LatLng> points = [];
        for(var i = 0;i<widget.currentTrack.positions.length;i++){
          double? lat = widget.currentTrack.positions[i].latitude;
          double? lon = widget.currentTrack.positions[i].longitude;
          if(lat != null && lon != null) points.add(LatLng(lat,lon));
        }
        Polyline recordingPolyline = Polyline(polylineId: PolylineId('recordingPolyline'), points: points, width: 5, color: CustomColors.ownPath);
        if(this.mounted) setState(() {
          _polyline.removeWhere((element) => element.polylineId.value == 'recordingPolyline');
          _polyline.add(recordingPolyline);
        });
      }
    });
  }

  stopRecording(){
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Stop recording and save your track?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => _insertName(),
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => _stopAndDiscard(),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  _insertName(){
    Navigator.pop(context, 'Stop and save');
    String name = '';
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Form(
            key: _formKey,
            child:TextFormField(decoration: InputDecoration(labelText: 'Name'), onChanged: (value) => {name = value},validator: (text) {
              if (text == null || text.isEmpty) {
                return "Empty name";
              }
              name = text;
              return null;
            })),
        actions: <Widget>[
          TextButton(
            onPressed: () => _stopAndSave(name),
            child: const Text('Ok'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  _stopAndSave(name) async{
    if(!_formKey.currentState!.validate()) return;
    Navigator.pop(context, 'Ok');
    _location.enableBackgroundMode(enable: false);
    widget.setPlayIcon();
    Gpx gpx = Gpx();
    gpx.metadata = Metadata(name: name);
    gpx.version = '1.1';
    gpx.creator = 'vieiros';
    for(var i = 0; i<widget.currentTrack.waypoints.length; i++){
      gpx.wpts.add(Wpt(lat: widget.currentTrack.waypoints[i].position.latitude, lon: widget.currentTrack.waypoints[i].position.longitude, ele: widget.currentTrack.waypoints[i].position.elevation, name: widget.currentTrack.waypoints[i].name));
    }
    List<Wpt> wpts = [];
    for(var i = 0; i<widget.currentTrack.positions.length; i++){
      wpts.add(Wpt(lat: widget.currentTrack.positions[i].latitude, lon: widget.currentTrack.positions[i].longitude, ele: widget.currentTrack.positions[i].elevation, time: DateTime.fromMillisecondsSinceEpoch(widget.currentTrack.positions[i].timestamp!.toInt())));
    }
    List<Trkseg> trksegs = [];
    trksegs.add(Trkseg(trkpts: wpts));
    gpx.trks.add(Trk(name: name, trksegs: trksegs));
    final gpxString = GpxWriter().asString(gpx, pretty: true);
    _writeFile(gpxString, name);
    if(this.mounted) setState(() {
      _polyline.removeWhere((element) => element.polylineId.value == 'recordingPolyline');
      widget.currentTrack.clear();
    });
  }

  void _writeFile(gpxString, name) async{
    bool hasPermission = await _checkWritePermission();
    if(hasPermission){
      final directory = await AndroidPathProvider.downloadsPath;
      String path = directory+'/'+name.replaceAll(' ','_')+'.gpx';
      await File(path).writeAsString(gpxString);
      String? jsonString = widget.prefs.getString('files');
      if(jsonString != null){
        List<GpxFile> files = (json.decode(jsonString) as List).map((i) =>
            GpxFile.fromJson(i)).toList();
        files.add(GpxFile(name: name, path: path));
        widget.prefs.setString('files', jsonEncode(files));
      }
    }
  }

  Future<bool> _checkWritePermission() async{
    bool hasPermission = await permission_handler.Permission.storage.isGranted;
    if(!hasPermission){
      final status = await permission_handler.Permission.storage.request();
      if(status == permission_handler.PermissionStatus.granted){
        return true;
      }else{
        return false;
      }
    }
    return true;
  }

  _stopAndDiscard(){
    _location.enableBackgroundMode(enable: false);
    Navigator.pop(context, 'Stop and discard');
    widget.setPlayIcon();
    if(this.mounted) setState(() {
      _polyline.removeWhere((element) => element.polylineId.value == 'recordingPolyline');
      widget.currentTrack.clear();
    });
  }

  //Workaround for choppy Maps initialization
  bool showMap = false;

  @override
  void initState() {
    super.initState();
    loadCurrentTrack();
    getLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
        child: showMap
            ? GoogleMap(
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                  new Factory<OneSequenceGestureRecognizer>(
                        () => new EagerGestureRecognizer(),
                  ),
                ].toSet(),
                mapType: MapType.hybrid,
                mapToolbarEnabled: true,
                buildingsEnabled: false,
                initialCameraPosition:
                    CameraPosition(target: new LatLng(0.0, 0.0), zoom: 15.0),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                compassEnabled: true,
                polylines: _polyline,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                },
              ): Center(
                child: CircularProgressIndicator(
                color: CustomColors.accent,
              )));
  }

  @override
  bool get wantKeepAlive => true;
}
