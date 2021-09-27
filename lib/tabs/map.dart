import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vieiros/components/vieiros_dialog.dart';
import 'package:vieiros/components/vieiros_notification.dart';
import 'package:vieiros/components/vieiros_text_input.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/model/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:vieiros/utils/calc.dart';
import 'package:vieiros/utils/files_handler.dart';
import 'package:vieiros/utils/gpx_handler.dart';
import 'package:vieiros/utils/permission_handler.dart';
import 'package:vieiros/utils/vieiros_tts.dart';

class Map extends StatefulWidget {
  final Function setPlayIcon;
  final CurrentTrack currentTrack;
  final LoadedTrack loadedTrack;
  final SharedPreferences prefs;

  const Map(
      {Key? key,
      required this.setPlayIcon,
      required this.prefs,
      required this.currentTrack,
      required this.loadedTrack})
      : super(key: key);

  @override
  MapState createState() => MapState();
}

class MapState extends State<Map> with AutomaticKeepAliveClientMixin {
  final Location _location = Location();
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Polyline> _polyline = {};
  final Set<Marker> _markers = {};
  List<Marker> _currentMarkers = [];
  final _formKey = GlobalKey<FormState>();
  final _formKeyWaypointAdd = GlobalKey<FormState>();
  final _formKeyWaypointEdit = GlobalKey<FormState>();

  getLocation() async {
    bool _hasPermissions = await PermissionHandler().handleLocationPermission();
    if (_hasPermissions) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showMap = true;
            _showWarning = false;
          });
        }
      });
      _location.changeNotificationOptions(
          iconName: 'ic_stat_name',
          color: CustomColors.accent,
          onTapBringToFront: true,
          title: I18n.translate('map_notification_title'),
          description: I18n.translate('map_notification_desc'));
      _location.changeSettings(interval: 5000, distanceFilter: 10);
      LocationData _locationData;
      final GoogleMapController controller = await _mapController.future;

      _locationData = await _location.getLocation();
      double? lat = _locationData.latitude;
      double? lon = _locationData.longitude;
      if (lat != null && lon != null && widget.loadedTrack.gpx == null) {
        controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(lat, lon), zoom: 15.0)));
      }
    } else {
      setState(() {
        _showWarning = true;
      });
    }
  }

  addMarkerSet(LatLng latLng, bool isWayPoint, String? description,
      GoogleMapController controller) async {
    BitmapDescriptor icon;
    if (!isWayPoint) {
      if (description == I18n.translate('map_track_pin_start')) {
        icon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(100, 100)), 'assets/loaded_pin.png');
      } else {
        icon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(100, 100)),
            'assets/loaded_pin_end.png');
      }
    } else {
      icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(100, 100)),
          'assets/loaded_waypoint.png');
    }
    MarkerId markerId = MarkerId(const Uuid().v4());
    Marker marker;
    if (description != null && description.isNotEmpty) {
      marker = Marker(
          markerId: markerId,
          position: latLng,
          icon: icon,
          infoWindow: InfoWindow(title: description),
          onTap: () => controller.showMarkerInfoWindow(markerId));
    } else {
      marker = Marker(markerId: markerId, position: latLng, icon: icon);
    }
    if (mounted) {
      setState(() {
        _markers.add(marker);
      });
    }
  }

  loadTrack(path) async {
    await widget.loadedTrack.loadTrack(path);
    loadCurrentTrack();
  }

  navigateTrack(path) async {
    navigateCurrentTrack();
  }

  clearTrack() {
    if (mounted) {
      setState(() {
        _polyline.removeWhere(
                (element) => element.polylineId.value == 'loadedTrack');
        _markers.removeWhere((element) => element.markerId.value != 'recordingPin');
        for (var element in _currentMarkers) {_markers.add(element);}
      });
    }
  }

  navigateCurrentTrack() async {
    final GoogleMapController controller = await _mapController.future;
    if (widget.loadedTrack.gpx != null && _polyline.isNotEmpty && _polyline.first.points.isNotEmpty) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _polyline.first.points.first, zoom: 14.0)));
    }
  }

  loadCurrentTrack() async {
    clearTrack();
    final GoogleMapController controller = await _mapController.future;
    if (widget.loadedTrack.gpx != null) {
      List<LatLng> points = GpxHandler().getPointsFromGpx(widget.loadedTrack);
      Gpx gpx = widget.loadedTrack.gpx!;
      for (var element in gpx.wpts) {
        if (element.lat == null || element.lon == null) return;
        addMarkerSet(LatLng(element.lat!, element.lon!), true, element.name, controller);
      }
      Polyline polyline = Polyline(
          polylineId: const PolylineId('loadedTrack'),
          points: points,
          width: 5,
          color: CustomColors.accent);
      addMarkerSet(points.first, false, I18n.translate('map_track_pin_start'),
          controller);
      addMarkerSet(points.last, false, I18n.translate('map_track_pin_finish'),
          controller);
      if (mounted) {
        setState(() {
          _polyline.add(polyline);
        });
      }
      if (points.isEmpty) return;
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: points.first, zoom: 14.0)));
    }
  }

  startRecording() async {
    VieirosNotification().showNotification(
        context, 'map_start_recording_message', NotificationType.info);
    widget.currentTrack.setRecording(true);
    widget.currentTrack.dateTime = DateTime.now();
    _location.enableBackgroundMode(enable: true);
    int _referenceDistance = 1000;
    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)), 'assets/current_pin.png');
    Marker? _marker;
    _location.onLocationChanged.listen((event) async {
      if (widget.currentTrack.isRecording) {
        widget.currentTrack.addPosition(
            RecordedPosition(event.latitude, event.longitude, event.altitude, event.time));
        Calc().setGain(widget.currentTrack);
        Calc().setTop(widget.currentTrack);
        Calc().setMin(widget.currentTrack);
        Calc().addDistance(widget.currentTrack);
        if (widget.currentTrack.positions.length == 1) {
          _marker = Marker(
              markerId: const MarkerId('recordingPin'),
              position: LatLng(widget.currentTrack.positions.first.latitude!,
                  widget.currentTrack.positions.first.longitude!),
              icon: icon);
        }
        int dist = widget.currentTrack.distance;
        if (dist > _referenceDistance &&
            (widget.prefs.getString("voice_alerts") == null ||
                widget.prefs.getString("voice_alerts") == 'true')) {
          VieirosTts().speakDistance(dist, widget.currentTrack.dateTime!);
          _referenceDistance += 1000;
        }
        if (mounted){
          List<LatLng> points = widget.currentTrack.getPoints();
          setState(() {
            if (points.length == 1) {
              Polyline _recordingPolyline = Polyline(
                  polylineId: const PolylineId('recordingPolyline'),
                  points: points,
                  width: 5,
                  color: CustomColors.ownPath);
              _polyline.add(_recordingPolyline);
              _markers.add(_marker!);
            }else{
              _polyline.singleWhere((element) => element.polylineId.value == 'recordingPolyline').points.add(points.last);
            }
          });
        }
      }
    });
  }

  _currentMarkerDialog(LatLng latLng) {
    if (!widget.currentTrack.isRecording) return;
    String name = '';
    VieirosDialog().inputDialog(
        context,
        'map_waypoint',
        {
          'common_cancel': () => Navigator.pop(context, 'map_waypoint'),
          'common_ok': () => _addCurrentMarker(latLng, name, false, null)
        },
        form: Form(
            key: _formKeyWaypointAdd,
            child: VieirosTextInput(
              hintText: 'common_name',
              onChanged: (value) => {name = value},
            )));
  }

  _addCurrentMarker(
      LatLng latLng, String name, bool edit, MarkerId? markerId) async {
    if (edit) {
      if (!_formKeyWaypointEdit.currentState!.validate()) return;
      Navigator.pop(context, I18n.translate('common_edit'));
    } else {
      if (!_formKeyWaypointAdd.currentState!.validate()) return;
      Navigator.pop(context, I18n.translate('common_ok'));
    }
    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        'assets/current_waypoint.png');
    MarkerId mrkId;
    if (edit && markerId != null) {
      mrkId = markerId;
    } else {
      mrkId = MarkerId(const Uuid().v4());
    }
    Marker marker = Marker(
        markerId: mrkId,
        position: latLng,
        icon: icon,
        infoWindow: InfoWindow(title: name),
        onTap: () => _editMarkerDialog(mrkId, latLng, name));
    if (mounted) {
      setState(() {
        if (edit) {
          _markers
              .removeWhere((element) => element.markerId.value == mrkId.value);
          _currentMarkers
              .removeWhere((element) => element.markerId.value == mrkId.value);
        }
        _currentMarkers.add(marker);
        _markers.add(marker);
      });
    }
  }

  _editMarkerDialog(MarkerId markerId, LatLng latLng, String name) {
    VieirosDialog().inputDialog(
        context,
        'map_waypoint',
        {
          'common_cancel': () => Navigator.pop(context, 'map_waypoint'),
          'common_delete': () => _removeMarker(markerId),
          'common_edit': () => _addCurrentMarker(latLng, name, true, markerId)
        },
        form: Form(
            key: _formKeyWaypointEdit,
            child: VieirosTextInput(
                hintText: 'common_name',
                initialValue: name,
                onChanged: (value) => {name = value})));
  }

  _removeMarker(MarkerId markerId) {
    Navigator.pop(context, I18n.translate('common_delete'));
    if (mounted) {
      setState(() {
        _markers
            .removeWhere((element) => element.markerId.value == markerId.value);
        _currentMarkers
            .removeWhere((element) => element.markerId.value == markerId.value);
      });
    }
  }

  stopRecording() {
    VieirosDialog().infoDialog(
        context,
        'map_finish_tracking',
        {
          'common_cancel': () => Navigator.pop(context, ''),
          'common_discard': () => _stopAndDiscard(),
          'common_save': () => _insertName()
        },
        bodyTag: 'map_stop_save');
  }

  _insertName() {
    Navigator.pop(context, 'Stop and save');
    String name = '';
    VieirosDialog().inputDialog(
        context,
        'map_track_name',
        {
          'common_cancel': () => Navigator.pop(context, ''),
          'common_ok': () => _stopAndSave(name),
        },
        form: Form(
            key: _formKey,
            child: VieirosTextInput(
              hintText: 'common_name',
              onChanged: (value) => {name = value},
            )));
  }

  _stopAndSave(name) async {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, I18n.translate('common_ok'));
    _location.enableBackgroundMode(enable: false);
    widget.setPlayIcon();
    Gpx gpx = GpxHandler().createGpx(widget.currentTrack, name, currentMarkers: _currentMarkers);
    final gpxString = GpxWriter().asString(gpx, pretty: true);
    await FilesHandler().writeFile(gpxString, name, widget.prefs, true);
    if (mounted) {
      setState(() {
        _polyline.removeWhere(
            (element) => element.polylineId.value == 'recordingPolyline');
        widget.currentTrack.clear();
        for (var i = 0; i < _currentMarkers.length; i++) {
          _markers.removeWhere((element) =>
              element.markerId.value == _currentMarkers[i].markerId.value);
        }
        _currentMarkers = [];
        _markers
            .removeWhere((element) => element.markerId.value == 'recordingPin');
        _currentMarkers = [];
      });
    }
  }

  void _stopAndDiscard() {
    _location.enableBackgroundMode(enable: false);
    Navigator.pop(context, 'Stop and discard');
    widget.setPlayIcon();
    if (mounted) {
      setState(() {
        _polyline.removeWhere(
            (element) => element.polylineId.value == 'recordingPolyline');
        widget.currentTrack.clear();
        for (var i = 0; i < _currentMarkers.length; i++) {
          _markers.removeWhere((element) =>
              element.markerId.value == _currentMarkers[i].markerId.value);
        }
        _currentMarkers = [];
        _markers
            .removeWhere((element) => element.markerId.value == 'recordingPin');
      });
    }
  }

  //Workaround for choppy Maps initialization
  bool _showMap = false;

  bool _showWarning = false;

  void _refreshTab() async {
    bool _hasPermission = await PermissionHandler().handleLocationPermission();
    if (_hasPermission) {
      setState(() {
        _showMap = true;
        _showWarning = false;
      });
    }
  }

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
    bool lightMode = Provider.of<ThemeProvider>(context).isLightMode;
    return SafeArea(
        child: _showWarning
            ? Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                            I18n.translate('map_permissions_request'),
                            style: TextStyle(
                                color: lightMode
                                    ? CustomColors.subText
                                    : CustomColors.subTextDark))),
                    ElevatedButton(
                        onPressed: _refreshTab,
                        child:
                            Text(I18n.translate('map_grant_permissions')))
                  ],
                ))
            : _showMap
                ? GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    mapType: MapType.hybrid,
                    mapToolbarEnabled: false,
                    buildingsEnabled: false,
                    initialCameraPosition: const CameraPosition(
                        target: LatLng(43.463305, -8.273529), zoom: 15.0),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    trafficEnabled: false,
                    compassEnabled: true,
                    polylines: _polyline,
                    markers: _markers,
                    onLongPress: _currentMarkerDialog,
                    onMapCreated: (GoogleMapController controller) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(controller);
                      }
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(
                    color: CustomColors.accent,
                  )));
  }

  @override
  bool get wantKeepAlive => true;
}
