import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vieiros/components/tracks/bottom_sheet_actions.dart';
import 'package:vieiros/components/tracks/loading_track_info.dart';
import 'package:vieiros/components/tracks/track_info_track_altitude.dart';
import 'package:vieiros/components/tracks/track_info_track_distance.dart';
import 'package:vieiros/components/tracks/track_info_track_name.dart';
import 'package:vieiros/components/tracks/track_info_track_time.dart';
import 'package:vieiros/model/track.dart';
import 'package:vieiros/model/track_minimap_info_data.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/utils/calc.dart';
import 'package:vieiros/utils/gpx_handler.dart';

class TrackInfo extends StatefulWidget {
  final bool lightMode;
  final List<Track> tracks;
  final Map<String, Map<String, dynamic>> actions;
  final BitmapDescriptor iconStart;
  final BitmapDescriptor iconEnd;
  final Function onIndexChange;

  const TrackInfo(
      {super.key,
      required this.lightMode,
      required this.tracks,
      required this.actions,
      required this.iconStart,
      required this.iconEnd,
      required this.onIndexChange});

  @override
  TrackInfoState createState() => TrackInfoState();
}

class TrackInfoState extends State<TrackInfo> {
  PageController? _pageController;
  int _currentTrackIndex = 0;
  List<Track> _trackList = [];
  String? _totalTime;
  DateTime? _initTime;
  Track? _currentTrack;
  TrackMiniMapInfoData? mapInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _trackList = widget.tracks;
    _pageController = PageController(initialPage: 0);
    if (_trackList.isNotEmpty) {
      setTrackList(tracks: widget.tracks);
    }
  }

  _onIndexChange({required int value}) {
    setTrackList(tracks: _trackList, index: value);
    widget.onIndexChange(value: value);
  }

  void setTrackList({required List<Track> tracks, int? index, bool? fromSave}) {
    setState(() {
      _loading = true;
    });
    Timer(const Duration(milliseconds: 200), () {
      int currentTrackIndex = index ?? _currentTrackIndex;
      if (tracks.isNotEmpty) {
        Track currentTrack = tracks.elementAt(currentTrackIndex);
        if (fromSave != null && fromSave) {
          _pageController!.jumpToPage(currentTrackIndex);
        }

        String totalTime = currentTrack.gpx!.trks.first.trksegs.first.trkpts.last.time!
            .difference(currentTrack.gpx!.trks.first.trksegs.first.trkpts.first.time!)
            .abs()
            .toString()
            .split('.')
            .first
            .padLeft(8, "0");
        DateTime? initTime = currentTrack.gpx!.trks.first.trksegs.first.trkpts.first.time;

        setState(() {
          _trackList = tracks;
          _currentTrackIndex = currentTrackIndex;
          mapInfo = _setCurrentTrackData(index: currentTrackIndex);
          _currentTrack = tracks.elementAt(currentTrackIndex);
          _initTime = initTime;
          _totalTime = totalTime;
          _loading = false;
        });
      }
    });
  }

  TrackMiniMapInfoData _setCurrentTrackData({required int index}) {
    Track track = _trackList.elementAt(index);

    List<LatLng> points = GpxHandler().getPointsFromGpx(track);

    Marker start = Marker(markerId: const MarkerId('track_preview_start'), position: points.first, icon: widget.iconStart);

    Marker end = Marker(markerId: const MarkerId('track_preview_start'), position: points.last, icon: widget.iconEnd);

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

    Set<Polyline> polyLines = {};
    polyLines.add(polyline);

    Map<String, double> center = Calc().getPolygonCenter(points: points);

    return TrackMiniMapInfoData(markers: markers, polyline: polyLines, centerLat: center['lat']!, centerLon: center['lon']!);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * .9;

    return Ink(
        height: height,
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        color: widget.lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 1,
                child: PageView.builder(
                    itemCount: _trackList.isEmpty ? 1 : _trackList.length,
                    onPageChanged: (value) => _onIndexChange(value: value),
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      return _loading
                          ? LoadingTrackInfo(lightMode: widget.lightMode)
                          : Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                              TrackInfoTrackName(
                                trackName: _currentTrack!.gpx!.trks.first.name.toString(),
                                lightMode: widget.lightMode,
                              ),
                              Expanded(
                                child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    width: width,
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(12)),
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
                                            polylines: mapInfo!.polyline,
                                            markers: mapInfo!.markers,
                                            initialCameraPosition: CameraPosition(
                                              target: LatLng(mapInfo!.centerLat, mapInfo!.centerLon),
                                              zoom: 13,
                                            )))),
                              ),
                              Container(
                                  margin: const EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, mainAxisSize: MainAxisSize.max, children: [
                                        TrackInfoTrackDistance(lightMode: widget.lightMode, distance: _currentTrack!.distance),
                                        TrackInfoTrackTime(lightMode: widget.lightMode, totalTime: _totalTime, initTime: _initTime)
                                      ]),
                                      TrackInfoTrackAltitude(
                                          lightMode: widget.lightMode,
                                          altitudeTop: _currentTrack!.altitudeTop.toString(),
                                          altitudeGain: _currentTrack!.altitudeGain.toString(),
                                          altitudeMin: _currentTrack!.altitudeMin.toString(),
                                          avgSlope: _currentTrack!.avgSlope.toInt().toString())
                                    ],
                                  ))
                            ]);
                    })),
            _trackList.length > 1
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(_trackList.length, (index) {
                      return Container(
                        margin: const EdgeInsets.all(3),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                            color: _currentTrackIndex == index
                                ? (widget.lightMode ? CustomColors.subText : CustomColors.subTextDark)
                                : (widget.lightMode ? CustomColors.faintedText : CustomColors.subText),
                            shape: BoxShape.circle),
                      );
                    }))
                : const SizedBox(),
            BottomSheetActions(actions: widget.actions, lightMode: widget.lightMode, loading: _loading)
          ],
        )));
  }
}
