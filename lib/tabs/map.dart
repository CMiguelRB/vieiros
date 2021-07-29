import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget{

  Map({Key? key}) : super(key: key);


  _Map createState() => _Map();
}

class _Map extends State<Map> with AutomaticKeepAliveClientMixin{
  Completer<GoogleMapController> _mapController = Completer();

  void _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return print('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    Position? position;
    if (permission == LocationPermission.denied) {
      LocationPermission request = await Geolocator.requestPermission();
      if (request == LocationPermission.denied ||
          request == LocationPermission.deniedForever) {
        return print('Location permissions are denied');
      } else {
        position = await Geolocator.getCurrentPosition();
      }
    } else {
      position = await Geolocator.getCurrentPosition();
    }
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 15.0)));

  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: GoogleMap(
      mapType: MapType.hybrid,
      mapToolbarEnabled: true,
      buildingsEnabled: false,
      initialCameraPosition:
      CameraPosition(target: new LatLng(0.0, 0.0), zoom: 15.0),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      indoorViewEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        if (!_mapController.isCompleted) {
          _mapController.complete(controller);
        }
      },
    )
    );
  }

  @override
  bool get wantKeepAlive => true;
}