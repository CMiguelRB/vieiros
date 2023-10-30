import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';
import 'package:vieiros/components/info/altitude_widget.dart';
import 'package:vieiros/components/info/chart_widget.dart';
import 'package:vieiros/components/info/daytime_widget.dart';
import 'package:vieiros/components/info/distance_widget.dart';
import 'package:vieiros/components/info/pace_widget.dart';
import 'package:vieiros/components/info/time_widget.dart';
import 'package:vieiros/components/vieiros_segmented_control.dart';
import 'package:vieiros/model/altitude_point.dart';
import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:vieiros/utils/calc.dart';
import 'package:vieiros/utils/permission_handler.dart';

class Info extends StatefulWidget {
  final CurrentTrack currentTrack;
  final LoadedTrack loadedTrack;

  const Info({super.key, required this.currentTrack, required this.loadedTrack});

  @override
  InfoState createState() => InfoState();
}

enum InfoDisplay { current, loaded }

class InfoState extends State<Info> with AutomaticKeepAliveClientMixin {
  InfoDisplay currentDisplaySet = InfoDisplay.current;
  String _distanceUnit = 'Km';
  String _distance = '0';
  String _totalTime = '--:--:--';
  String _avgPace = '00:00';
  final String _paceUnit = 'min/Km';
  String _altitude = '-';
  int _altitudeMin = 0;
  String _altitudeGain = '-';
  String _altitudeCurrent = '-';
  final String _altitudeUnit = 'm';
  bool _loadingAltitudeChart = true;
  String currentPath = '';
  DateTime? _sunset;
  String _sunsetTime = '--:--';
  String _toSunset = '--:--';
  String _avgSlope = '0';
  final String _avgSlopeUnit = '%';
  Color _chartColor = CustomColors.accent;
  Color _chartColorFainted = CustomColors.faintedFaintedAccent;
  bool _started = false;
  List<AltitudePoint> _altitudeDataLoaded = [];
  List<AltitudePoint> _altitudeDataCurrent = [];

  final List<ButtonSegment> _tabMap = [
    ButtonSegment<InfoDisplay>(value: InfoDisplay.current, label: Text(I18n.translate('info_current_track')), icon: null),
    ButtonSegment<InfoDisplay>(value: InfoDisplay.loaded, label: Text(I18n.translate('info_loaded_track')), icon: null)
  ];

  Map axisValuesCenter = {'mainAxisSize': MainAxisSize.max, 'mainAxisAlignment': MainAxisAlignment.center};

  @override
  void initState() {
    super.initState();
    clearScreen();
    _loadTrackData();
    widget.currentTrack.eventListener.listen((_) => recordingListener());
    widget.loadedTrack.eventListener.listen((_) => clearLoadedListener());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void recordingListener() {
    if (widget.currentTrack.isRecording) {
      if (widget.currentTrack.positions.isNotEmpty) {
        _getDaylight();
        _loadTrackData();
        if (!_started) {
          setState(() {
            currentDisplaySet = InfoDisplay.current;
            _started = true;
          });
        }
      }
    } else {
      clearScreen();
      _loadTrackData();
      setState(() {
        currentDisplaySet = InfoDisplay.loaded;
      });
    }
  }

  void clearLoadedListener() {
    setState(() {
      currentDisplaySet = InfoDisplay.current;
    });
    if (!widget.currentTrack.isRecording) {
      clearScreen();
    }
  }

  _getDaylight() async {
    if (widget.currentTrack.isRecording) {
      _sunset = getSunriseSunset(widget.currentTrack.positions.last.latitude!, widget.currentTrack.positions.last.longitude!,
              DateTime.now().timeZoneOffset, DateTime.now().toLocal())
          .sunset;
      setState(() {
        _sunsetTime = Calc().getSunsetTime(widget.currentTrack.positions.last.latitude, widget.currentTrack.positions.last.longitude, _sunset!);
        _toSunset = Calc().getDaylight(_sunset!);
      });
    } else {
      bool hasPermissions = await PermissionHandler().handleLocationPermission();
      if (hasPermissions) {
        Position position = await Geolocator.getCurrentPosition();
        _sunset = getSunriseSunset(position.latitude, position.longitude, DateTime.now().timeZoneOffset, DateTime.now().toLocal()).sunset;
        setState(() {
          _sunsetTime = Calc().getSunsetTime(position.latitude, position.longitude, _sunset!);
          _toSunset = Calc().getDaylight(_sunset!);
        });
      }
    }
  }

  loadTrack(path) async {
    await widget.loadedTrack.loadTrack(path);
    _loadTrackData();
  }

  void _loadTrackData() async {
    int totalDistance = 0;
    double avgPaceSeconds = 0.0;
    String avgPaceMin = '';
    String avgPaceSec = '';

    if (widget.currentTrack.isRecording && currentDisplaySet == InfoDisplay.current) {
      totalDistance = widget.currentTrack.distance;
      avgPaceSeconds = Calc().avgPaceSecs(widget.currentTrack);
      avgPaceMin = Calc().avgPaceMinString(avgPaceSeconds);
      avgPaceSec = Calc().avgPaceSecString(avgPaceSeconds);
      if (mounted) {
        setState(() {
          _chartColor = CustomColors.ownPath;
          _chartColorFainted = CustomColors.ownPathFainted;
          _avgPace = '$avgPaceMin:$avgPaceSec';
          _distance = totalDistance > 1000 ? (totalDistance / 1000).toStringAsFixed(2) : totalDistance.toString();
          _distanceUnit = totalDistance > 1000 ? 'Km' : 'm';
          _altitude = widget.currentTrack.altitudeTop.toString();
          _avgSlope = widget.currentTrack.avgSlope.toInt().toString();
          _altitudeMin = widget.currentTrack.altitudeMin;
          _altitudeGain = widget.currentTrack.altitudeGain.toString();
          if (widget.currentTrack.positions.isNotEmpty) {
            _altitudeCurrent = widget.currentTrack.positions.last.altitude!.round().toString();
          }
          List<AltitudePoint> data = _altitudeDataCurrent;
          if (data.isEmpty) {
            int totalDistanceDataCurrent = 0;
            for (int i = 0; i < widget.currentTrack.positions.length; i++) {
              _altitudeDataCurrent.add(AltitudePoint(totalDistanceDataCurrent, widget.currentTrack.positions[i].altitude!));
              if (i > 0) {
                totalDistanceDataCurrent = totalDistanceDataCurrent +
                    Geolocator.distanceBetween(widget.currentTrack.positions[(i - 1)].latitude!, widget.currentTrack.positions[(i - 1)].longitude!,
                            widget.currentTrack.positions[i].latitude!, widget.currentTrack.positions[i].longitude!)
                        .toInt();
              }
            }
          } else if (data.last.totalDistance != totalDistance) {
            _altitudeDataCurrent.add(AltitudePoint(totalDistance, widget.currentTrack.positions.last.altitude!));
          }
          _loadingAltitudeChart = false;
        });
      }
    } else {
      if (widget.loadedTrack.gpx == null) return clearScreen();
      List<AltitudePoint> altitudePoints = widget.loadedTrack.altitudePoints;
      Gpx gpx = widget.loadedTrack.gpx as Gpx;
      DateTime? timeStart = gpx.trks[0].trksegs[0].trkpts.first.time;
      DateTime? timeEnd = gpx.trks[0].trksegs[0].trkpts.last.time;
      totalDistance = widget.loadedTrack.distance;
      avgPaceSeconds = timeEnd!.difference(timeStart!).abs().inMilliseconds / 1000 / (totalDistance / 1000);
      avgPaceMin = Calc().avgPaceMinString(avgPaceSeconds);
      avgPaceSec = Calc().avgPaceSecString(avgPaceSeconds);
      if (mounted) {
        setState(() {
          _chartColor = CustomColors.accent;
          _chartColorFainted = CustomColors.faintedFaintedAccent;
          _avgPace = '$avgPaceMin:$avgPaceSec';
          _distance = totalDistance > 1000 ? (totalDistance / 1000).toStringAsFixed(2) : totalDistance.toString();
          _distanceUnit = totalDistance > 1000 ? 'Km' : 'm';
          _altitude = widget.loadedTrack.altitudeTop.toString();
          _altitudeMin = widget.loadedTrack.altitudeMin;
          _altitudeGain = widget.loadedTrack.altitudeGain.toString();
          _avgSlope = widget.loadedTrack.avgSlope.toInt().toString();
          _totalTime = timeEnd.difference(timeStart).abs().toString().split('.').first.padLeft(8, "0");
          _altitudeDataLoaded = altitudePoints;
          _loadingAltitudeChart = false;
        });
      }
    }
  }

  void clearLoaded() {
    if (!widget.currentTrack.isRecording) {
      clearLoadedChart();
    }
  }

  clearLoadedChart() {
    _altitudeDataLoaded = [];
  }

  void clearScreen() {
    if (mounted) {
      setState(() {
        _chartColor = CustomColors.accent;
        _chartColorFainted = CustomColors.faintedFaintedAccent;
        _loadingAltitudeChart = false;
        _totalTime = '--:--:--';
        _distance = '0';
        _distanceUnit = 'm';
        _altitude = '-';
        _altitudeMin = 0;
        _altitudeGain = '-';
        _altitudeCurrent = '-';
        _avgSlope = '0';
        _started = false;
        _avgPace = '00:00';
        //_sunsetTime = '--:--';
        _altitudeDataCurrent = [];
        clearLoadedChart();
      });
    }
  }

  _slidingStateChanged(Set value) {
    if (mounted) {
      setState(() {
        currentDisplaySet = value.first;
      });
      _loadTrackData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool lightMode = Provider.of<ThemeProvider>(context).isLightMode;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Column(children: [
      widget.currentTrack.isRecording && widget.loadedTrack.gpx != null
          ? VieirosSegmentedControl(
              infoDisplaySet: <InfoDisplay>{currentDisplaySet},
              tabMap: _tabMap,
              onValueChanged: _slidingStateChanged,
            )
          : const SizedBox(),
      Flexible(
          flex: 1,
          child: Column(children: [
            Flexible(
                flex: 2,
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, mainAxisSize: MainAxisSize.max, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TimeWidget(
                        lightMode: lightMode,
                        slideState: currentDisplaySet,
                        initDatetime: widget.currentTrack.dateTime,
                        isRecording: widget.currentTrack.isRecording,
                        totalTime: _totalTime,
                        width: width,
                      ),
                      DistanceWidget(lightMode: lightMode, distance: _distance, distanceUnit: _distanceUnit, width: width)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      InkWell(onTap: _getDaylight, child: DaytimeWidget(lightMode: lightMode, sunsetTime: _sunsetTime, toSunset: _toSunset)),
                      PaceWidget(lightMode: lightMode, avgPace: _avgPace, paceUnit: _paceUnit)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AltitudeWidget(
                        lightMode: lightMode,
                        altitudeUnit: _altitudeUnit,
                        altitude: _altitude,
                        altitudeGain: _altitudeGain,
                        altitudeCurrent: _altitudeCurrent,
                        avgSlope: _avgSlope,
                        avgSlopeUnit: _avgSlopeUnit,
                        width: width,
                        isAltitudeMin: false,
                      )
                    ],
                  )
                ])),
            Flexible(
                flex: 1,
                child: Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 20, right: 25, left: 15),
                    child: _loadingAltitudeChart
                        ? const CircularProgressIndicator(
                            color: CustomColors.accent,
                          )
                        : ChartWidget(
                            lightMode: lightMode,
                            altitudeData: currentDisplaySet == InfoDisplay.current && widget.currentTrack.isRecording
                                ? _altitudeDataCurrent
                                : _altitudeDataLoaded,
                            chartColor: _chartColor,
                            chartColorFainted: _chartColorFainted,
                            altitude: _altitude,
                            altitudeMin: _altitudeMin,
                            distance: _distance)))
          ]))
    ]));
  }
}
