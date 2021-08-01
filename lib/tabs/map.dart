import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vieiros/model/position.dart';
import 'package:xml/xml.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/resources/CustomColors.dart';

class Map extends StatefulWidget {
  Map({Key? key}) : super(key: key);
  MapState createState() => MapState();
}

class MapState extends State<Map> with AutomaticKeepAliveClientMixin{
  Completer<GoogleMapController> _mapController = Completer();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Set<Polyline> _polyline = Set();
  Set<Marker> _markers = Set();
  bool recording = false;
  List<RecordedPosition> recordedPositions = [];

  getLocation() async {
    Location location = new Location();
    _handlePermissions(location);
    location.changeNotificationOptions(iconName: 'vieiros_logo_notification',color: CustomColors.accent);
    location.enableBackgroundMode(enable: true);
    LocationData _locationData;
    final GoogleMapController controller = await _mapController.future;
    List<RecordedPosition> recordedPositions = [];

    location.onLocationChanged.listen((event) {
      double? lat = event.latitude;
      double? lon = event.longitude;
      recordedPositions.add(RecordedPosition(lat, lon, event.altitude, event.time));
      List<LatLng> points = [];
      for(var i = 0;i<recordedPositions.length;i++){
        double? lat = recordedPositions[i].latitude;
        double? lon = recordedPositions[i].longitude;
        if(lat != null && lon != null) points.add(LatLng(lat,lon));
      }
      Polyline recordingPolyline = Polyline(polylineId: PolylineId('recordingPolyline'), points: points, width: 5, color: CustomColors.ownPath);
      setState(() {
        _polyline.removeWhere((element) => element.polylineId.value == 'recordingPolyline');
        _polyline.add(recordingPolyline);
      });
    });



    _locationData = await location.getLocation();
    double? lat = _locationData.latitude;
    double? lon = _locationData.longitude;
    if(lat != null && lon != null){
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(lat, lon), zoom: 15.0)));
    }
  }

  _handlePermissions(location) async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
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
    if(description != null && description != ''){
      marker = Marker(markerId: markerId, position: latLng, icon: icon, infoWindow: InfoWindow(title: description), onTap: () => controller.showMarkerInfoWindow(markerId));
    }else{
      marker = Marker(markerId: markerId, position: latLng, icon: icon);
    }
    setState(() {
      _markers.add(marker);
    });
  }

  loadCurrentTrack() async {
    _polyline.clear();
    _markers.clear();
    final GoogleMapController controller = await _mapController.future;
    final prefs = await _prefs;
    String? path = prefs.getString('currentTrack');
    if (path == null) return;
    final xmlFile = new File(path);
    Gpx gpx = GpxReader().fromString(XmlDocument.parse(xmlFile.readAsStringSync()).toXmlString());
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
    setState(() {
      _polyline.add(polyline);
    });
    if(lat == null || lon == null) return;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: first, zoom: 14.0)));
  }

  //Workaround for choppy Maps initialization
  bool showMap = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        showMap = true;
      });
    });
    //loadCurrentTrack();
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
