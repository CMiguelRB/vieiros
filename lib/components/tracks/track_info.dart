import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vieiros/components/info/altitude_widget.dart';
import 'package:vieiros/components/info/distance_widget.dart';
import 'package:vieiros/components/tracks/bottom_sheet_actions.dart';
import 'package:vieiros/model/track.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/utils/gpx_handler.dart';

class TrackInfo extends StatelessWidget {
  final bool lightMode;
  final Track track;
  final Map<String, Map<String, dynamic>> actions;
  final BitmapDescriptor iconStart;
  final BitmapDescriptor iconEnd;

  const TrackInfo(
      {Key? key,
      required this.lightMode,
      required this.track,
      required this.actions,
        required this.iconStart,
        required this.iconEnd
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<LatLng> points = GpxHandler().getPointsFromGpx(track);

    Marker start = Marker(markerId: const MarkerId('track_preview_start'), position: points.first, icon: iconStart);

    Marker end = Marker(markerId: const MarkerId('track_preview_start'), position: points.last, icon: iconEnd);

    Set<Marker> markers = {};
    markers.add(start);
    markers.add(end);

    Polyline polyline = Polyline(
        polylineId: const PolylineId('track_preview'),
        points: points,
        width: 5,
        color: CustomColors.accent);

    Set<Polyline> polylines = {};
    polylines.add(polyline);

    double maxX = -90;
    double minX = 90;
    double maxY = -180;
    double minY = 180;
    for(LatLng latLng in points){
      if(latLng.latitude > maxY){
        maxY = latLng.latitude;
      }
      if(latLng.latitude < minY){
        minY = latLng.latitude;
      }
      if(latLng.longitude > maxX){
        maxX = latLng.longitude;
      }
      if(latLng.longitude < minX){
        minX = latLng.longitude;
      }
    }

    double centerLon = (maxX + minX)/2;
    double centerLat = (maxY + minY)/2;

    return Ink(
        height: MediaQuery.of(context).size.height * .9,
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        color:
            lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 1,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                          margin: const EdgeInsets.all(20),
                          child: Text(
                            track.gpx!.trks.first.name.toString(),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          )),

                            Expanded(
                              child:
                                  Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      width: MediaQuery.of(context).size.width,
                                      child: GoogleMap(
                                        liteModeEnabled: true,
                                        compassEnabled: false,
                                        buildingsEnabled: false,
                                        mapType: MapType.satellite,
                                        mapToolbarEnabled: false,
                                        myLocationButtonEnabled: false,
                                        myLocationEnabled: false,
                                        indoorViewEnabled: false,
                                        zoomControlsEnabled: false,
                                        zoomGesturesEnabled: false,
                                        trafficEnabled: false,
                                        scrollGesturesEnabled: false,
                                        rotateGesturesEnabled: false,
                                        polylines: polylines,
                                        markers: markers,
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(centerLat, centerLon),
                                          zoom: 13,
                                        ),
                                        onMapCreated: (controller) async {
                                          Uint8List? uInt8list =
                                              await controller.takeSnapshot();
                                          log(base64Encode(uInt8list!));
                                        },
                                      ))
                                ,
                            ),
                            Container(
                                margin: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    DistanceWidget(lightMode: lightMode, distance: (track.distance/1000).toStringAsFixed(2), distanceUnit: 'Km'),
                                    AltitudeWidget(lightMode: lightMode, altitudeUnit: 'm', altitude: track.altitudeTop.toString(), altitudeGain: track.altitudeGain.toString(), altitudeCurrent: track.altitudeMin.toString(), width: MediaQuery.of(context).size.width-40, isAltitudeMin: true)
                                  ],
                                ))

                    ])),
            BottomSheetActions(actions: actions, lightMode: lightMode)
          ],
        )));
  }
}
