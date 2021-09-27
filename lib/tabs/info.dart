import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';
import 'package:vieiros/components/info/altitude_widget.dart';
import 'package:vieiros/components/info/chart_point_info_widget.dart';
import 'package:vieiros/components/info/chart_widget.dart';
import 'package:vieiros/components/info/daytime_widget.dart';
import 'package:vieiros/components/info/distance_widget.dart';
import 'package:vieiros/components/info/pace_widget.dart';
import 'package:vieiros/components/info/time_widget.dart';
import 'package:vieiros/components/vieiros_segmented_control.dart';
import 'package:vieiros/model/altitude_point.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:vieiros/utils/calc.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Info extends StatefulWidget {
  final CurrentTrack currentTrack;
  final LoadedTrack loadedTrack;
  final SharedPreferences prefs;

  const Info(
      {Key? key,
      required this.currentTrack,
      required this.prefs,
      required this.loadedTrack})
      : super(key: key);

  @override
  InfoState createState() => InfoState();
}

class InfoState extends State<Info> with AutomaticKeepAliveClientMixin {
  int _slideState = 0;
  AltitudePoint? _selectedPoint;
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
  Color _chartColor = CustomColors.accent;
  List<charts.Series<AltitudePoint, num>> _altitudeDataLoaded = [];
  List<charts.Series<AltitudePoint, num>> _altitudeDataCurrent = [];
  final Map<int, Widget> _tabMap = {
    0: Text(I18n.translate('info_current_track')),
    1: Text(I18n.translate('info_loaded_track'))
  };

  Map axisValuesCenter = {
    'mainAxisSize': MainAxisSize.max,
    'mainAxisAlignment': MainAxisAlignment.center
  };

  @override
  void initState() {
    super.initState();
    clearScreen();
    _loadTrackData();
    widget.currentTrack.eventListener.listen((_) => recordingListener());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void recordingListener() {
    if (widget.currentTrack.isRecording) {
      if (widget.currentTrack.positions.length == 1) {
        setState(() {
          _slideState = 0;
        });
      }
      if (widget.currentTrack.positions.isNotEmpty) {
        _getDaylight();
        _loadTrackData();
      }
    } else {
      clearScreen();
      _loadTrackData();
      setState(() {
        _slideState = 1;
      });
    }
  }

  _getDaylight() {
    _sunset = getSunriseSunset(
            widget.currentTrack.positions.last.latitude!,
            widget.currentTrack.positions.last.longitude!,
            DateTime.now().timeZoneOffset.inHours,
            DateTime.now())
        .sunset;
    setState(() {
      _sunsetTime = Calc().getSunsetTime(widget.currentTrack, _sunset!);
      _toSunset = Calc().getDaylight(widget.currentTrack, _sunset!);
    });
  }

  loadTrack(path) async {
    await widget.loadedTrack.loadTrack(path);
    _loadTrackData();
  }

  void _loadTrackData() async {
    int _totalDistance = 0;
    double _avgPaceSeconds = 0.0;
    String _avgPaceMin = '';
    String _avgPaceSec = '';

    if (widget.currentTrack.isRecording && _slideState == 0) {
      _totalDistance = widget.currentTrack.distance;
      _avgPaceSeconds = Calc().avgPaceSecs(widget.currentTrack);
      _avgPaceMin = Calc().avgPaceMinString(_avgPaceSeconds);
      _avgPaceSec = Calc().avgPaceSecString(_avgPaceSeconds);
      if (mounted) {
        setState(() {
          _chartColor = CustomColors.ownPath;
          _avgPace = _avgPaceMin + ':' + _avgPaceSec;
          _distance = _totalDistance > 1000
              ? (_totalDistance / 1000).toStringAsFixed(2)
              : _totalDistance.toString();
          _distanceUnit = _totalDistance > 1000 ? 'Km' : 'm';
          _altitude = widget.currentTrack.altitudeTop.toString();
          _altitudeMin = widget.currentTrack.altitudeMin;
          _altitudeGain = widget.currentTrack.altitudeGain.toString();
          if (widget.currentTrack.positions.isNotEmpty) {
            _altitudeCurrent =
                widget.currentTrack.positions.last.altitude!.round().toString();
          }
          List<AltitudePoint> data = _altitudeDataCurrent.first.data;
          if (data.isEmpty) {
            _altitudeDataCurrent.first.data.add(AltitudePoint(
                _totalDistance, widget.currentTrack.positions.last.altitude!));
          } else if (data.last.totalDistance != _totalDistance) {
            _altitudeDataCurrent.first.data.add(AltitudePoint(
                _totalDistance, widget.currentTrack.positions.last.altitude!));
          }
          _loadingAltitudeChart = false;
        });
      }
    } else {
      if (widget.loadedTrack.gpx == null) return clearScreen();
      List<AltitudePoint> _altitudePoints = widget.loadedTrack.altitudePoints;
      Gpx _gpx = widget.loadedTrack.gpx as Gpx;
      DateTime? _timeStart = _gpx.trks[0].trksegs[0].trkpts.first.time;
      DateTime? _timeEnd = _gpx.trks[0].trksegs[0].trkpts.last.time;
      _totalDistance = widget.loadedTrack.distance;
      _avgPaceSeconds = _timeEnd!.difference(_timeStart!).abs().inMilliseconds /
          1000 /
          (_totalDistance / 1000);
      _avgPaceMin = Calc().avgPaceMinString(_avgPaceSeconds);
      _avgPaceSec = Calc().avgPaceSecString(_avgPaceSeconds);
      if (mounted) {
        setState(() {
          _chartColor = CustomColors.accent;
          _avgPace = _avgPaceMin + ':' + _avgPaceSec;
          _distance = _totalDistance > 1000
              ? (_totalDistance / 1000).toStringAsFixed(2)
              : _totalDistance.toString();
          _distanceUnit = _totalDistance > 1000 ? 'Km' : 'm';
          _altitude = widget.loadedTrack.altitudeTop.toString();
          _altitudeMin = widget.loadedTrack.altitudeMin;
          _altitudeGain = widget.loadedTrack.altitudeGain.toString();
          _totalTime = _timeEnd
              .difference(_timeStart)
              .abs()
              .toString()
              .split('.')
              .first
              .padLeft(8, "0");
          _altitudeDataLoaded = [
            charts.Series<AltitudePoint, int>(
                id: 'altitude',
                colorFn: (_, __) => charts.Color(
                    r: _chartColor.red,
                    g: _chartColor.green,
                    b: _chartColor.blue),
                domainFn: (AltitudePoint point, _) => point.totalDistance,
                measureFn: (AltitudePoint point, _) => point.altitude,
                strokeWidthPxFn: (datum, index) => 1,
                data: _altitudePoints)
          ];
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
    _altitudeDataLoaded = [
      charts.Series<AltitudePoint, int>(
          id: 'altitude',
          colorFn: (_, __) => charts.Color(
              r: _chartColor.red, g: _chartColor.green, b: _chartColor.blue),
          domainFn: (AltitudePoint point, _) => point.totalDistance,
          measureFn: (AltitudePoint point, _) => point.altitude,
          strokeWidthPxFn: (datum, index) => 1,
          data: [])
    ];
  }

  void clearScreen() {
    if (mounted) {
      setState(() {
        _selectedPoint = null;
        _chartColor = CustomColors.accent;
        _loadingAltitudeChart = false;
        _totalTime = '--:--:--';
        _distance = '0';
        _distanceUnit = 'm';
        _altitude = '-';
        _altitudeMin = 0;
        _altitudeGain = '-';
        _altitudeCurrent = '-';
        _avgPace = '00:00';
        //_sunsetTime = '--:--';
        _altitudeDataCurrent = [
          charts.Series<AltitudePoint, int>(
              id: 'altitude',
              colorFn: (_, __) => charts.Color(
                  r: _chartColor.red,
                  g: _chartColor.green,
                  b: _chartColor.blue),
              domainFn: (AltitudePoint point, _) => point.totalDistance,
              measureFn: (AltitudePoint point, _) => point.altitude,
              strokeWidthPxFn: (datum, index) => 1,
              data: [])
        ];
        clearLoadedChart();
      });
    }
  }

  _slidingStateChanged(value) {
    if (mounted) {
      setState(() {
        _slideState = int.parse(value!.toString());
      });
      _loadTrackData();
    }
  }

  _onChangeSelectedPoint(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    if (selectedDatum.isNotEmpty && mounted) {
      setState(() {
        _selectedPoint = selectedDatum.first.datum;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool lightMode = Provider.of<ThemeProvider>(context).isLightMode;
    return SafeArea(
        child: Column(children: [
      widget.currentTrack.isRecording && widget.loadedTrack.gpx != null
          ? VieirosSegmentedControl(
              slideState: _slideState,
              tabMap: _tabMap,
              onValueChanged: _slidingStateChanged,
            )
          : Container(),
      Flexible(
          flex: 1,
          child: Column(children: [
            Flexible(
                flex: 2,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          TimeWidget(
                            lightMode: lightMode,
                            slideState: _slideState,
                            initDatetime: widget.currentTrack.dateTime,
                            isRecording: widget.currentTrack.isRecording,
                            totalTime: _totalTime,
                          ),
                          DistanceWidget(
                              lightMode: lightMode,
                              distance: _distance,
                              distanceUnit: _distanceUnit)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          DaytimeWidget(
                              lightMode: lightMode,
                              sunsetTime: _sunsetTime,
                              toSunset: _toSunset),
                          PaceWidget(
                              lightMode: lightMode,
                              avgPace: _avgPace,
                              paceUnit: _paceUnit)
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
                              altitudeCurrent: _altitudeCurrent)
                        ],
                      )
                    ])),
            Flexible(
                flex: 1,
                child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ChartPointInfoWidget(selectedPoint: _selectedPoint),
                          _loadingAltitudeChart
                              ? const CircularProgressIndicator(
                                  color: CustomColors.accent,
                                )
                              : ChartWidget(
                                  lightMode: lightMode,
                                  altitudeData: _slideState == 0 &&
                                          widget.currentTrack.isRecording
                                      ? _altitudeDataCurrent
                                      : _altitudeDataLoaded,
                                  altitude: _altitude,
                                  altitudeMin: _altitudeMin,
                                  distance: _distance,
                                  onChangeSelected: _onChangeSelectedPoint)
                        ])))
          ]))
    ]));
  }

  @override
  bool get wantKeepAlive => true;
}
