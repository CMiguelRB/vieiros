import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vieiros/components/info/altitude_widget.dart';
import 'package:vieiros/components/info/distance_widget.dart';
import 'package:vieiros/components/info/time_widget.dart';
import 'package:vieiros/components/tracks/bottom_sheet_actions.dart';
import 'package:vieiros/model/track.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/utils/gpx_handler.dart';

class TrackInfo extends StatefulWidget {
  final bool lightMode;
  final List<Track> tracks;
  final Map<String, Map<String, dynamic>> actions;
  final BitmapDescriptor iconStart;
  final BitmapDescriptor iconEnd;

  const TrackInfo({Key? key,
    required this.lightMode,
    required this.tracks,
    required this.actions,
    required this.iconStart,
    required this.iconEnd})
      : super(key: key);

  @override
  TrackInfoState createState() => TrackInfoState();
}

class TrackInfoState extends State<TrackInfo> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Ink(
        height: MediaQuery.of(context).size.height * .9,
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        color:
        widget.lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(flex: 1, child: PageView.builder(
                    itemCount: widget.tracks.length,
                    pageSnapping: true,
                    onPageChanged: (value) => setState(() {
                      _currentIndex = value;
                    }),
                    itemBuilder: (context,index){
                      Track track = widget.tracks.elementAt(index);
                      List<LatLng> points = GpxHandler().getPointsFromGpx(track);

                      Marker start = Marker(
                          markerId: const MarkerId('track_preview_start'),
                          position: points.first,
                          icon: widget.iconStart);

                      Marker end = Marker(
                          markerId: const MarkerId('track_preview_start'),
                          position: points.last,
                          icon: widget.iconEnd);

                      Set<Marker> markers = {};
                      markers.add(start);
                      markers.add(end);

                      Polyline polyline = Polyline(
                          polylineId: const PolylineId('track_preview'),
                          points: points,
                          width: 3,
                          endCap: Cap.roundCap,
                          startCap: Cap.roundCap,
                          color: CustomColors.accent);

                      Set<Polyline> polylines = {};
                      polylines.add(polyline);

                      double maxX = -90;
                      double minX = 90;
                      double maxY = -180;
                      double minY = 180;
                      for (LatLng latLng in points) {
                        if (latLng.latitude > maxY) {
                          maxY = latLng.latitude;
                        }
                        if (latLng.latitude < minY) {
                          minY = latLng.latitude;
                        }
                        if (latLng.longitude > maxX) {
                          maxX = latLng.longitude;
                        }
                        if (latLng.longitude < minX) {
                          minX = latLng.longitude;
                        }
                      }

                      double centerLon = (maxX + minX) / 2;
                      double centerLat = (maxY + minY) / 2;

                      double width = MediaQuery.of(context).size.width;

                      String totalTime = track.gpx!.trks.first.trksegs.first.trkpts.last.time!
                          .difference(track.gpx!.trks.first.trksegs.first.trkpts.first.time!)
                          .abs()
                          .toString()
                          .split('.')
                          .first
                          .padLeft(8, "0");
                      DateTime? initTime = track.gpx!.trks.first.trksegs.first.trkpts.first.time;
                      return  Column(
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
                              child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  width: width,
                                  child: ClipRRect(
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(12)),
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
                                          )
                                      ))),
                            ),
                            Container(
                                margin: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Card(
                                              elevation: 0,
                                              color: widget.lightMode
                                                  ? CustomColors.faintedFaintedAccent
                                                  : CustomColors.trackBackgroundDark,
                                              child: (Container(
                                                  margin: const EdgeInsets.symmetric(
                                                      vertical: 4),
                                                  child: DistanceWidget(
                                                    lightMode: widget.lightMode,
                                                    distance: (track.distance / 1000)
                                                        .toStringAsFixed(2),
                                                    distanceUnit: 'Km',
                                                    width: width - 60,
                                                  )))),
                                          Card(
                                              elevation: 0,
                                              color: widget.lightMode
                                                  ? CustomColors.faintedFaintedAccent
                                                  : CustomColors.trackBackgroundDark,
                                              child: (Container(
                                                  margin: const EdgeInsets.symmetric(
                                                      vertical: 4),
                                                  child: TimeWidget(
                                                    lightMode: widget.lightMode,
                                                    slideState: 0,
                                                    isRecording: false,
                                                    totalTime: totalTime,
                                                    initDatetime: initTime,
                                                    width: width - 60,
                                                  ))))
                                        ]),
                                    Card(
                                        elevation: 0,
                                        color: widget.lightMode
                                            ? CustomColors.faintedFaintedAccent
                                            : CustomColors.trackBackgroundDark,
                                        child: (Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: AltitudeWidget(
                                                lightMode: widget.lightMode,
                                                altitudeUnit: 'm',
                                                altitude:
                                                track.altitudeTop.toString(),
                                                altitudeGain:
                                                track.altitudeGain.toString(),
                                                altitudeCurrent:
                                                track.altitudeMin.toString(),
                                                width: width - 40,
                                                isAltitudeMin: true))))
                                  ],
                                ))
                          ]);
                    }
                )),
                widget.tracks.length > 1 ?
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(widget.tracks.length, (index) {
                      return Container(
                        margin: const EdgeInsets.all(3),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                            color: _currentIndex == index ? (widget.lightMode ? CustomColors.subText : CustomColors.subTextDark) : (widget.lightMode ? CustomColors.faintedText : CustomColors.subText),
                            shape: BoxShape.circle),
                      );
                    })) : Container()
                ,
                BottomSheetActions(actions: widget.actions, lightMode: widget.lightMode)
              ],
            )));
  }

}
