import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:image/image.dart' as image;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vieiros/components/vieiros_dialog.dart';
import 'package:vieiros/components/vieiros_notification.dart';
import 'package:vieiros/components/vieiros_text_input.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/model/pk_marker.dart';
import 'package:vieiros/model/position.dart';
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
import 'package:vieiros/utils/preferences.dart';
import 'package:vieiros/utils/vieiros_tts.dart';

class Map extends StatefulWidget {
  final CurrentTrack currentTrack;
  final LoadedTrack loadedTrack;

  const Map({Key? key, required this.currentTrack, required this.loadedTrack}) : super(key: key);

  @override
  MapState createState() => MapState();
}

class MapState extends State<Map> with AutomaticKeepAliveClientMixin {
  final Location _location = Location();
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Polyline> _polyline = {};
  final Set<Marker> _markers = {};
  List<Marker> _currentMarkers = [];
  Icon _fabIcon = const Icon(Icons.play_arrow);
  final _formKey = GlobalKey<FormState>();
  final _formKeyWaypointAdd = GlobalKey<FormState>();
  final _formKeyWaypointEdit = GlobalKey<FormState>();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool offTrack = false;
  bool _showBearingButton = false;
  double _bearing = 0.0;

  //Workaround for choppy Maps initialization
  bool _showMap = false;
  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    loadLoadedTrack();
    getLocation();
    _initializeNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshTab() async {
    bool hasPermission = await PermissionHandler().handleLocationPermission();
    if (hasPermission) {
      setState(() {
        _showMap = true;
        _showWarning = false;
      });
    }
  }

  _initializeNotifications() async {
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('ic_stat_name');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  getLocation() async {
    bool hasPermissions = await PermissionHandler().handleLocationPermission();
    if (hasPermissions) {
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
          color: CustomColors.faintedFaintedAccent,
          channelName: I18n.translate('map_channel_name_location'),
          onTapBringToFront: true,
          title: I18n.translate('map_notification_title'),
          description: I18n.translate('map_notification_desc'));
      _location.changeSettings(interval: 2000, distanceFilter: 5, accuracy: LocationAccuracy.high);
      LocationData locationData;
      final GoogleMapController controller = await _mapController.future;

      locationData = await _location.getLocation();
      double? lat = locationData.latitude;
      double? lon = locationData.longitude;
      if (lat != null && lon != null && widget.loadedTrack.gpx == null) {
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lon), zoom: 15.0)));
      }
    } else {
      setState(() {
        _showWarning = true;
      });
    }
  }

  addMarkerSet(LatLng latLng, bool isWayPoint, String? description, GoogleMapController controller) async {
    BitmapDescriptor icon;
    if (!isWayPoint) {
      if (description == I18n.translate('map_track_pin_start')) {
        icon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(100, 100)), 'assets/loaded_pin.png');
      } else {
        icon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(100, 100)), 'assets/loaded_pin_end.png');
      }
    } else {
      icon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(100, 100)), 'assets/loaded_waypoint.png');
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
    loadLoadedTrack();
  }

  clearTrack() {
    if (mounted) {
      setState(() {
        _polyline.removeWhere((element) => element.polylineId.value.contains('loadedTrack'));
        _markers.removeWhere((element) => !element.markerId.value.contains('##'));
        for (int i = 0; i < _currentMarkers.length; i++) {
          _markers.add(_currentMarkers[i]);
        }
      });
    }
  }

  navigateCurrentTrack() async {
    if (!widget.currentTrack.isRecording) {
      final GoogleMapController controller = await _mapController.future;
      if (widget.loadedTrack.gpx != null && _polyline.isNotEmpty && _polyline.first.points.isNotEmpty) {
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _polyline.first.points.first, zoom: 14.0)));
      }
    }
  }

  loadLoadedTrack() async {
    clearTrack();
    final GoogleMapController controller = await _mapController.future;
    if (widget.loadedTrack.gpx != null) {
      Gpx gpx = widget.loadedTrack.gpx!;
      List<Wpt> points = gpx.trks.first.trksegs.first.trkpts;
      for (int i = 0; i < gpx.wpts.length; i++) {
        if (gpx.wpts[i].lat == null || gpx.wpts[i].lon == null) return;
        addMarkerSet(LatLng(gpx.wpts[i].lat!, gpx.wpts[i].lon!), true, gpx.wpts[i].name, controller);
      }
      String? gradientPolyline = Preferences().get("gradient_mode");
      int referenceDistance = 1000;
      double distance = 0;
      double slopeReferenceDistance = 100;
      double slopeStart = points.first.ele!;
      Wpt? prevPoint;
      List<LatLng> pointsAux = [];
      double startingAltitude = points.first.ele!;
      String currentRange = '0';
      for (int i = 0; i < points.length - 1; i++) {
        pointsAux.add(LatLng(points[i].lat!, points[i].lon!));
        if (i > 0) {
          distance = distance + geolocator.Geolocator.distanceBetween(points[i].lat!, points[i].lon!, points[i - 1].lat!, points[i - 1].lon!);
          if (distance > referenceDistance) {
            referenceDistance += 1000;
            _setPKMarker(RecordedPosition(points[i].lat, points[i].lon, null, null), ((referenceDistance ~/ 1000) - 1).toString());
          }
          if (gradientPolyline != null && gradientPolyline == "slope") {
            if (distance >= slopeReferenceDistance) {
              slopeReferenceDistance += 100;
              double slopeEnd = points[i].ele!;
              int gradient = (slopeEnd - slopeStart).toInt();
              slopeStart = slopeEnd;
              String gradientColor = _checkGradient(gradient);
              if (prevPoint != null) {
                pointsAux.insert(0, LatLng(prevPoint.lat!, prevPoint.lon!));
              }
              pointsAux = _setGradientPolyline(pointsAux, gradientColor, i.toString(), "slope");
              prevPoint = points[i];
            }
          }
          if (gradientPolyline != null && gradientPolyline == "altitude") {
            String range = _checkRange(points[i], startingAltitude);
            if (range != currentRange) {
              if (prevPoint != null) {
                pointsAux.insert(0, LatLng(prevPoint.lat!, prevPoint.lon!));
              }
              pointsAux = _setGradientPolyline(pointsAux, currentRange, i.toString(), "altitude");
              currentRange = range;
              prevPoint = points[i];
            }
          }
        }
      }
      if (prevPoint != null) {
        pointsAux.insert(0, LatLng(prevPoint.lat!, prevPoint.lon!));
      }
      if (gradientPolyline != null && gradientPolyline == "slope") {
        double slopeEnd = points.last.ele!;
        int gradient = (slopeEnd - slopeStart).toInt();
        slopeStart = slopeEnd;
        String gradientColor = _checkGradient(gradient);
        pointsAux = _setGradientPolyline(pointsAux, gradientColor, 'last', "slope");
      } else if (gradientPolyline != null && gradientPolyline == 'altitude') {
        currentRange = _checkRange(points.last, startingAltitude);
        pointsAux = _setGradientPolyline(pointsAux, currentRange, 'last', "altitude");
      } else {
        List<LatLng> points = GpxHandler().getPointsFromGpx(widget.loadedTrack);
        Polyline polyline = Polyline(polylineId: const PolylineId('loadedTrack'), points: points, width: 5, color: CustomColors.accent);
        if (mounted) {
          setState(() {
            _polyline.add(polyline);
          });
        }
      }
      addMarkerSet(LatLng(points.first.lat!, points.first.lon!), false, I18n.translate('map_track_pin_start'), controller);
      addMarkerSet(LatLng(points.last.lat!, points.last.lon!), false, I18n.translate('map_track_pin_finish'), controller);
      if (points.isEmpty) return;
      if (widget.currentTrack.isRecording) return;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(points.first.lat!, points.first.lon!), zoom: 14.0)));
    }
  }

  String _checkRange(Wpt point, double startingAltitude) {
    int diff = (point.ele! - startingAltitude).toInt();
    if (diff <= 100 && diff > -100) return '0';
    if (diff > 2000) return '2000';
    if (diff < -2000) return '-2000';
    return '${diff.toString().substring(0, diff.toString().length - 2)}00';
  }

  String _checkGradient(int gradient) {
    gradient = (gradient / 5).round() * 5;
    if (gradient <= 5 && gradient > 5) return '0';
    if (gradient > 50) return '50';
    if (gradient < -50) return '-50';
    return gradient.toString();
  }

  List<LatLng> _setGradientPolyline(List<LatLng> points, String range, String index, String type) {
    Color color;
    if (type == 'slope') {
      color = CustomColors.slopeGradient.where((element) => element['range'] == range).last['color'];
    } else {
      color = CustomColors.altitudeGradient.where((element) => element['range'] == range).last['color'];
    }
    String polIdSuffix = range + index;
    Polyline polyline = Polyline(
        polylineId: PolylineId('loadedTrack$polIdSuffix'), points: points, width: 5, endCap: Cap.roundCap, startCap: Cap.roundCap, color: color);
    if (mounted) {
      setState(() {
        _polyline.add(polyline);
      });
    }
    return [];
  }

  centerMapView() async {
    final GoogleMapController controller = await _mapController.future;
    if (widget.currentTrack.positions.isNotEmpty) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(widget.currentTrack.positions.last.latitude!, widget.currentTrack.positions.last.longitude!), zoom: 14.0)));
    }
  }

  startRecording() async {
    VieirosNotification().showNotification(context, 'map_start_recording_message', NotificationType.info);
    widget.currentTrack.setRecording(true);
    widget.currentTrack.dateTime = DateTime.now();
    _location.enableBackgroundMode(enable: true);
    int referenceDistance = 1000;
    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(100, 100)), 'assets/current_pin.png');
    Marker? marker;
    _location.onLocationChanged.listen((event) async {
      if (widget.currentTrack.isRecording) {
        _checkOffTrack(event);
        widget.currentTrack.addPosition(RecordedPosition(event.latitude, event.longitude, event.altitude, event.time!.toInt()));
        Calc().setGain(widget.currentTrack);
        Calc().setTop(widget.currentTrack);
        Calc().setMin(widget.currentTrack);
        Calc().addDistance(widget.currentTrack);
        if (widget.currentTrack.positions.length == 1) {
          marker = Marker(
              markerId: const MarkerId('recordingPin##'),
              position: LatLng(widget.currentTrack.positions.first.latitude!, widget.currentTrack.positions.first.longitude!),
              icon: icon);
        }
        int dist = widget.currentTrack.distance;
        String? voiceAlerts = Preferences().get("voice_alerts");
        if (dist > referenceDistance) {
          _setPKMarker(null, (referenceDistance ~/ 1000).toString());
          if (voiceAlerts == null || voiceAlerts == 'true') {
            VieirosTts().speakDistance(dist, widget.currentTrack.dateTime!);
          }
          referenceDistance += 1000;
        }
        if (mounted) {
          List<LatLng> points = widget.currentTrack.getPoints();
          setState(() {
            if (points.length == 1) {
              Polyline recordingPolyline =
                  Polyline(polylineId: const PolylineId('recordingPolyline'), points: points, width: 5, color: CustomColors.ownPath);
              _polyline.add(recordingPolyline);
              _markers.add(marker!);
            } else {
              _polyline.singleWhere((element) => element.polylineId.value == 'recordingPolyline').points.add(points.last);
            }
          });
        }
      }
    });
  }

  _onFabPressed(lightMode) {
    if (!widget.currentTrack.isRecording) {
      startRecording();
      setState(() {
        _fabIcon = const Icon(Icons.stop);
      });
    } else {
      stopRecording(lightMode);
      setState(() {
        _fabIcon = const Icon(Icons.play_arrow);
      });
    }
  }

  Future<Uint8List> _getBytesFromAsset(Uint8List b64Image, int width) async {
    ui.Codec codec = await ui.instantiateImageCodec(b64Image, targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  _setPKMarker(RecordedPosition? position, String distance) async {
    List<dynamic> pksJSON = json.decode(await rootBundle.loadString('assets/pkMarkers.json'));
    String suffix = position != null ? 'l' : 'r';
    String baseB64 = '';
    String num1B64 = '';
    String num2B64 = '';
    Uint8List markerIcon = Uint8List(0);
    if (int.parse(distance) >= 10) {
      for (int i = 0; i < pksJSON.length; i++) {
        PKMarker base = PKMarker.fromJson(pksJSON[i]);
        if (base.pk == 'clear$suffix') {
          baseB64 = base.marker;
        }
        if (base.pk == distance.split('')[0] + suffix) {
          num1B64 = base.marker;
        }
        if (base.pk == distance.split('')[1] + suffix) {
          num2B64 = base.marker;
        }
      }
      final image1 = image.decodePng(await _getBytesFromAsset(base64Decode(baseB64), 65));
      final image2 = image.decodePng(await _getBytesFromAsset(base64Decode(num1B64), 14));
      final image3 = image.decodePng(await _getBytesFromAsset(base64Decode(num2B64), 14));
      image.compositeImage(image1!, image2!, dstX: 18, dstY: 21);
      image.compositeImage(image1, image3!, dstX: 32, dstY: 21);
      markerIcon = await _getBytesFromAsset(image.encodePng(image1), 65);
    } else {
      for (int i = 0; i < pksJSON.length; i++) {
        PKMarker base = PKMarker.fromJson(pksJSON[i]);
        if (base.pk == 'clear$suffix') {
          baseB64 = base.marker;
        }
        if (base.pk == distance + suffix) {
          num1B64 = base.marker;
        }
      }
      final image1 = image.decodePng(await _getBytesFromAsset(base64Decode(baseB64), 65));
      final image2 = image.decodePng(await _getBytesFromAsset(base64Decode(num1B64), 14));
      image.compositeImage(image1!, image2!, dstX: 25, dstY: 21);
      markerIcon = await _getBytesFromAsset(image.encodePng(image1), 65);
    }
    BitmapDescriptor icon = BitmapDescriptor.fromBytes(markerIcon);
    Marker marker;
    if (position != null) {
      marker =
          Marker(markerId: MarkerId('km$distance'), position: LatLng(position.latitude! - 0.000008, position.longitude!), zIndex: 1000, icon: icon);
      setState(() {
        _markers.add(marker);
      });
    } else {
      marker = Marker(
          markerId: MarkerId('km$distance##'),
          position: LatLng(widget.currentTrack.positions.last.latitude! - 0.000008, widget.currentTrack.positions.last.longitude!),
          zIndex: 1000,
          icon: icon);
      setState(() {
        _markers.add(marker);
      });
    }
  }

  _checkOffTrack(LocationData event) {
    if (widget.loadedTrack.gpx != null) {
      List<Wpt> trackPoints = widget.loadedTrack.gpx!.trks[0].trksegs[0].trkpts;
      if (widget.loadedTrack.gpx != null && widget.currentTrack.positions.isNotEmpty) {
        for (int i = 0; i < trackPoints.length; i++) {
          double distance = geolocator.Geolocator.distanceBetween(
              widget.currentTrack.positions.last.latitude!, widget.currentTrack.positions.last.longitude!, trackPoints[i].lat!, trackPoints[i].lon!);
          if (distance < 30) {
            offTrack = false;
            return;
          }
        }
        if (offTrack != true) {
          offTrack = true;
          _showNotification();
        }
      }
    }
  }

  _currentMarkerDialog(LatLng latLng, bool lightMode) {
    if (!widget.currentTrack.isRecording) return;
    String name = '';
    VieirosDialog().inputDialog(
        context,
        'map_waypoint',
        {
          'common_save': () => _addCurrentMarker(latLng, name, false, lightMode, null),
          'common_cancel': () => Navigator.pop(context, 'map_waypoint'),
        },
        form: Form(
            key: _formKeyWaypointAdd,
            child: VieirosTextInput(
              lightMode: lightMode,
              hintText: 'common_name',
              onChanged: (value) => {name = value},
            )));
  }

  _addCurrentMarker(LatLng latLng, String name, bool edit, bool lightMode, MarkerId? markerId) async {
    if (edit) {
      if (!_formKeyWaypointEdit.currentState!.validate()) return;
      Navigator.pop(context, I18n.translate('common_edit'));
    } else {
      if (!_formKeyWaypointAdd.currentState!.validate()) return;
      Navigator.pop(context, I18n.translate('common_ok'));
    }
    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(100, 100)), 'assets/current_waypoint.png');
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
        onTap: () => _editMarkerDialog(mrkId, latLng, name, lightMode));
    if (mounted) {
      setState(() {
        if (edit) {
          _markers.removeWhere((element) => element.markerId.value == mrkId.value);
          _currentMarkers.removeWhere((element) => element.markerId.value == mrkId.value);
        }
        _currentMarkers.add(marker);
        _markers.add(marker);
      });
    }
  }

  _editMarkerDialog(MarkerId markerId, LatLng latLng, String name, bool lightMode) {
    VieirosDialog().inputDialog(
        context,
        'map_waypoint',
        {
          'common_cancel': () => Navigator.pop(context, 'map_waypoint'),
          'common_delete': () => _removeMarker(markerId),
          'common_edit': () => _addCurrentMarker(latLng, name, true, lightMode, markerId)
        },
        form: Form(
            key: _formKeyWaypointEdit,
            child: VieirosTextInput(lightMode: lightMode, hintText: 'common_name', initialValue: name, onChanged: (value) => {name = value})));
  }

  _removeMarker(MarkerId markerId) {
    Navigator.pop(context, I18n.translate('common_delete'));
    if (mounted) {
      setState(() {
        _markers.removeWhere((element) => element.markerId.value == markerId.value);
        _currentMarkers.removeWhere((element) => element.markerId.value == markerId.value);
      });
    }
  }

  stopRecording(bool lightMode) {
    String name = '';
    VieirosDialog().inputDialog(
        context,
        'map_track_name',
        {
          'common_discard': () => _stopAndDiscard(),
          'common_save': () => _stopAndSave(name),
        },
        form: Form(
            key: _formKey,
            child: VieirosTextInput(
              lightMode: lightMode,
              hintText: 'common_name',
              onChanged: (value) => {name = value},
            )));
  }

  _stopAndSave(String name) async {
    if (!_formKey.currentState!.validate()) return;
    _location.enableBackgroundMode(enable: false);
    Gpx gpx = GpxHandler().createGpx(widget.currentTrack, name, currentMarkers: _currentMarkers);
    String gpxString = GpxWriter().asString(gpx, pretty: true);
    //add namespaces
    gpxString = gpxString.replaceFirst(RegExp('creator="vieiros"'),
        'creator="vieiros" xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"');

    String? result = await FilesHandler().writeFile(gpxString, name.replaceRange(100,name.length, '...'), '', true);
    if (result == '###file_exists') {
      if (!mounted) return;
      return VieirosNotification().showNotification(context, I18n.translate('map_save_error_file_exists'), NotificationType.error);
    }
    if (!mounted) return;
    Navigator.pop(context, I18n.translate('common_ok'));
    if (mounted) {
      setState(() {
        _polyline.removeWhere((element) => element.polylineId.value == 'recordingPolyline');
        widget.currentTrack.clear();
        for (int i = 0; i < _currentMarkers.length; i++) {
          _markers.removeWhere((element) => element.markerId.value == _currentMarkers[i].markerId.value);
        }
        _currentMarkers = [];
        offTrack = false;
        _markers.removeWhere((element) => element.markerId.value.contains('##'));
        _currentMarkers = [];
      });
    }
  }

  void _stopAndDiscard() {
    _location.enableBackgroundMode(enable: false);
    Navigator.pop(context, 'Stop and discard');
    if (mounted) {
      setState(() {
        _polyline.removeWhere((element) => element.polylineId.value == 'recordingPolyline');
        widget.currentTrack.clear();
        offTrack = false;
        for (int i = 0; i < _currentMarkers.length; i++) {
          _markers.removeWhere((element) => element.markerId.value == _currentMarkers[i].markerId.value);
        }
        _currentMarkers = [];
        _markers.removeWhere((element) => element.markerId.value.contains('##'));
      });
    }
  }

  _showNotification() async {
    setState(() {
      offTrack = true;
    });
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('vieiros_notification_id', 'Vieiros',
        channelDescription: 'Vieiros notifications',
        importance: Importance.max,
        priority: Priority.high,
        color: CustomColors.accent,
        ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, I18n.translate('map_off_track_notification_title'), I18n.translate('map_off_track_notification_desc'), platformChannelSpecifics,
        payload: 'off track');
  }

  _resetBearing() async {
    final GoogleMapController controller = await _mapController.future;
    LatLngBounds latLngBounds = await controller.getVisibleRegion();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
          (latLngBounds.northeast.latitude + latLngBounds.southwest.latitude) / 2,
          (latLngBounds.northeast.longitude + latLngBounds.southwest.longitude) / 2,
        ),
        bearing: 0.0,
        zoom: 14.0)));
  }

  _moveCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    LocationData locationData = await _location.getLocation();
    controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(locationData.latitude!, locationData.longitude!), zoom: 14.0)));
  }

  _onCameraMove(CameraPosition camera) async {
    if (camera.bearing != 0.0 && !_showBearingButton) {
      setState(() {
        _showBearingButton = true;
      });
    }
    if (camera.bearing == 0.0 && _showBearingButton) {
      setState(() {
        _showBearingButton = false;
      });
    }
    if (camera.bearing != 0.0) {
      setState(() {
        _bearing = -camera.bearing * 3.14 / 180;
      });
    }
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
                        child: Text(I18n.translate('map_permissions_request'),
                            style: TextStyle(color: lightMode ? CustomColors.subText : CustomColors.subTextDark))),
                    ElevatedButton(onPressed: _refreshTab, child: Text(I18n.translate('map_grant_permissions')))
                  ],
                ))
            : _showMap
                ? Scaffold(
                    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                    floatingActionButton: FloatingActionButton(
                      heroTag: null,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
                      onPressed: () => _onFabPressed(lightMode),
                      child: _fabIcon,
                    ),
                    body: Scaffold(
                        body: GoogleMap(
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                            ),
                          },
                          mapType: MapType.hybrid,
                          mapToolbarEnabled: false,
                          buildingsEnabled: false,
                          initialCameraPosition: const CameraPosition(target: LatLng(43.463305, -8.273529), zoom: 15.0),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          trafficEnabled: false,
                          compassEnabled: false,
                          polylines: _polyline,
                          markers: _markers,
                          onCameraMove: _onCameraMove,
                          zoomControlsEnabled: false,
                          onLongPress: (latLng) => _currentMarkerDialog(latLng, lightMode),
                          onMapCreated: (GoogleMapController controller) {
                            if (!_mapController.isCompleted) {
                              _mapController.complete(controller);
                            }
                          },
                        ),
                        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
                        floatingActionButton: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FloatingActionButton(
                                  elevation: 0,
                                  mini: true,
                                  backgroundColor: const Color.fromARGB(95, 255, 255, 255),
                                  onPressed: _moveCurrentLocation,
                                  child: const Icon(Icons.my_location, color: CustomColors.trackBackgroundDark),
                                ),
                                Transform.rotate(
                                    angle: _bearing,
                                    child: FloatingActionButton(
                                      elevation: 0,
                                      mini: true,
                                      enableFeedback: _showBearingButton,
                                      backgroundColor: _showBearingButton ? const Color.fromARGB(95, 255, 255, 255) : Colors.transparent,
                                      onPressed: _showBearingButton ? _resetBearing : null,
                                      child:
                                          Icon(Icons.navigation, color: _showBearingButton ? CustomColors.trackBackgroundDark : Colors.transparent),
                                    ))
                              ],
                            ))))
                : const Center(
                    child: CircularProgressIndicator(
                    color: CustomColors.accent,
                  )));
  }

  @override
  bool get wantKeepAlive => true;
}
