import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';
import 'package:vieiros/model/elevation_point.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/resources/CustomColors.dart';

class Info extends StatefulWidget {
  final CurrentTrack currentTrack;
  final LoadedTrack loadedTrack;
  final SharedPreferences prefs;

  Info(
      {Key? key,
      required this.currentTrack,
      required this.prefs,
      required this.loadedTrack})
      : super(key: key);

  InfoState createState() => InfoState();
}

class InfoState extends State<Info> with AutomaticKeepAliveClientMixin {
  int? _slideState = 0;
  ElevationPoint? _selectedPoint;
  String _distanceUnit = 'Km';
  String _distance = '00.00';
  String _totalTime = '00:00:00';
  String _avgPace = '--:--';
  String _paceUnit = 'min/Km';
  String _elevation = '0';
  double _elevationMin = 0;
  String _elevationGain = '0';
  String _elevationCurrent = '-';
  String _elevationUnit = 'm';
  bool _loadingElevationChart = true;
  String currentPath = '';
  DateTime? _sunset;
  String _sunsetTime = '--:--';
  String _toSunset = '--:--';
  List<charts.Series<ElevationPoint, num>> _elevationData = [];
  Map<int, Widget> _tabMap = {
    0: Text('Current track'),
    1: Text('Loaded track')
  };
  bool _recording = true;

  Map axisValuesCenter = {
    'mainAxisSize': MainAxisSize.max,
    'mainAxisAlignment': MainAxisAlignment.center
  };

  @override
  void initState() {
    super.initState();
    //_getGeolocation();
    _loadTrackData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*_getDaylight() async {
    double? lat = locationData.latitude;
    double? lon = locationData.longitude;
    if (lat != null && lon != null && this.mounted) {
      setState(() {
        _sunset = getSunriseSunset(
                lat, lon, DateTime.now().timeZoneOffset.inHours, DateTime.now())
            .sunset;
        if (_sunset != null)
          _toSunset =
              DateTime.now().difference(_sunset!).abs().inHours.toString();
        if (_sunset != null)
          _toSunset = (DateTime.now().difference(_sunset!).abs().inMinutes -
                  (DateTime.now().difference(_sunset!).abs().inHours * 60))
              .toString();
      });
    }
  }*/

  loadTrack(path) async {
    await widget.loadedTrack.loadTrack(path);
    _loadTrackData();
  }

  /// Create one series with sample hard coded data.
  void _loadTrackData() async {
    List<ElevationPoint> elevationPoints = [];
    final chartColor = _recording ? CustomColors.ownPath : CustomColors.accent;
    if (widget.loadedTrack.gpx != null) {
      final latlong.Distance distance = new latlong.Distance();
      Gpx gpx = widget.loadedTrack.gpx as Gpx;
      latlong.LatLng first = latlong.LatLng(0, 0);
      double? lat;
      double? lon;
      double? ele;
      int totalDistance = 0;
      latlong.LatLng previous = latlong.LatLng(0, 0);
      DateTime? timeStart;
      DateTime? timeEnd;
      double maxElevation = 0;
      double minElevation = 8849;
      double previousElevation = 0;
      double elevationGain = 0;
      int totalPoints = gpx.trks[0].trksegs[0].trkpts.length;
      for (var i = 0; i < gpx.trks[0].trksegs[0].trkpts.length; i++) {
        if((totalPoints > 1000 && i%2 != 0)||(totalPoints > 2000 && i%3 != 0)||(totalPoints > 5000 && i%5 != 0)){
          continue;
        }
        lat = gpx.trks[0].trksegs[0].trkpts[i].lat;
        lon = gpx.trks[0].trksegs[0].trkpts[i].lon;
        ele = gpx.trks[0].trksegs[0].trkpts[i].ele;
        if (lat == null || lon == null || ele == null) continue;
        if (i == 0) {
          first = latlong.LatLng(lat, lon);
          previous = first;
          previousElevation = ele;
          timeStart = gpx.trks[0].trksegs[0].trkpts[i].time;
        }
        if (i == gpx.trks[0].trksegs[0].trkpts.length - 1) {
          timeEnd = gpx.trks[0].trksegs[0].trkpts[i].time;
        }
        if (ele > maxElevation) maxElevation = ele;
        if (ele < minElevation) minElevation = ele;
        double elevationDiff = ele - previousElevation;
        if (elevationDiff > 0) elevationGain += elevationDiff;
        int dist = distance
            .as(latlong.LengthUnit.Meter, latlong.LatLng(lat, lon), previous)
            .toInt();
        previous = latlong.LatLng(lat, lon);
        previousElevation = ele;
        totalDistance += dist;
        elevationPoints.add(ElevationPoint(totalDistance, ele));
      }
      double avgPaceSeconds = timeEnd!.difference(timeStart!).abs().inMilliseconds/1000 /
          (totalDistance / 1000);
      String avgPaceMin = (avgPaceSeconds / 60).toStringAsFixed(0);
      String avgPaceSec = (avgPaceSeconds % 60).toStringAsFixed(0);
      avgPaceMin = avgPaceMin.length > 1 ? avgPaceMin : "0$avgPaceMin";
      avgPaceSec = avgPaceSec.length > 1 ? avgPaceSec : "0$avgPaceSec";
      if (this.mounted)
        setState(() {
          currentPath = widget.loadedTrack.path as String;
          _totalTime = timeEnd!
              .difference(timeStart!)
              .abs()
              .toString()
              .split('.')
              .first
              .padLeft(8, "0");

          _avgPace = avgPaceMin + ':' + avgPaceSec;
          _distance = totalDistance > 1000
              ? (totalDistance / 1000).toStringAsFixed(2)
              : totalDistance.toString();
          _distanceUnit = totalDistance > 1000 ? 'Km' : 'm';
          _elevation = maxElevation.toInt().toString();
          _elevationMin = minElevation;
          _elevationGain = elevationGain.toInt().toString();
          _elevationData = [
            new charts.Series<ElevationPoint, int>(
                id: 'elevation',
                colorFn: (_, __) => charts.Color(
                    r: chartColor.red, g: chartColor.green, b: chartColor.blue),
                domainFn: (ElevationPoint point, _) => point.totalDistance,
                measureFn: (ElevationPoint point, _) => point.elevation,
                strokeWidthPxFn: (datum, index) => 1,
                data: elevationPoints)
          ];
          _loadingElevationChart = false;
        });
    } else {
      if (this.mounted)
        setState(() {
          _loadingElevationChart = false;
          _totalTime = '00:00:00';
          _distance = '0';
          _distanceUnit = 'm';
          _elevation = '0';
          _elevationMin = 0;
          _elevationGain = '0';
          _elevationData = [
            new charts.Series<ElevationPoint, int>(
                id: 'elevation',
                colorFn: (_, __) => charts.Color(
                    r: chartColor.red, g: chartColor.green, b: chartColor.blue),
                domainFn: (ElevationPoint point, _) => point.totalDistance,
                measureFn: (ElevationPoint point, _) => point.elevation,
                strokeWidthPxFn: (datum, index) => 1,
                data: elevationPoints)
          ];
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    /*final distance = _selectedPoint != null
        ? NumberFormat('###,###')
            .format(_selectedPoint!.totalDistance)
            .replaceAll(',', '.')
        : '';
    final elevation = '';*/

    return SafeArea(
        child: Column(children: [
      Container(
          child: _recording
              ? Container(
                  padding: EdgeInsets.only(top: 20),
                  child: CupertinoSlidingSegmentedControl(
                      children: _tabMap,
                      groupValue: _slideState,
                      onValueChanged: (value) {
                        if (this.mounted)
                          setState(() {
                            _slideState = int.parse(value!.toString());
                          });
                      }))
              : Container()),
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
                          Container(
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total time',
                                      style: TextStyle(
                                          color: CustomColors.subText)),
                                  Text(_totalTime,
                                      style: TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                              width: MediaQuery.of(context).size.width / 2,
                              alignment: Alignment.center),
                          Container(
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Distance',
                                      style: TextStyle(
                                          color: CustomColors.subText)),
                                  Container(
                                      child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(_distance,
                                                style: TextStyle(
                                                    fontSize: 35,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                margin: EdgeInsets.all(2)),
                                            Text(_distanceUnit,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ]),
                                      alignment: Alignment.center)
                                ],
                              ),
                              width: MediaQuery.of(context).size.width / 2,
                              alignment: Alignment.center)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Container(
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Daytime',
                                      style: TextStyle(
                                          color: CustomColors.subText)),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              'Hours left',
                                              style: TextStyle(
                                                  color: CustomColors.subText,
                                                  fontSize: 12),
                                            ),
                                            Text(_toSunset,
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ]),
                                      Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              'Sunset',
                                              style: TextStyle(
                                                  color: CustomColors.subText,
                                                  fontSize: 12),
                                            ),
                                            Text(_sunsetTime,
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ])
                                    ],
                                  )
                                ],
                              ),
                              width: MediaQuery.of(context).size.width / 2,
                              alignment: Alignment.center),
                          Container(
                            height: 80,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Avg pace',
                                    style:
                                        TextStyle(color: CustomColors.subText)),
                                Container(
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                      Text(_avgPace,
                                          style: TextStyle(
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold)),
                                      Container(margin: EdgeInsets.all(2)),
                                      Text(_paceUnit,
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold))
                                    ]))
                              ],
                            ),
                            width: MediaQuery.of(context).size.width / 2,
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Elevation',
                                      style: TextStyle(
                                          color: CustomColors.subText)),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              child: Text(
                                                'Current',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: CustomColors.subText,
                                                    fontSize: 12),
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              child: Text(
                                                'Top',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: CustomColors.subText,
                                                    fontSize: 12),
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              child: Text(
                                                'Gain',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: CustomColors.subText,
                                                    fontSize: 12),
                                              )),
                                        ],
                                      ),
                                      Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 3)),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.baseline,
                                                textBaseline:
                                                    TextBaseline.alphabetic,
                                                children: [
                                                  Text(_elevationCurrent,
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      _elevationCurrent != '-'
                                                          ? _elevationUnit
                                                          : '',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.baseline,
                                                textBaseline:
                                                    TextBaseline.alphabetic,
                                                children: [
                                                  Text(_elevation,
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(_elevationUnit,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.baseline,
                                                textBaseline:
                                                    TextBaseline.alphabetic,
                                                children: [
                                                  Text(_elevationGain,
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(_elevationUnit,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              ))
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              width: MediaQuery.of(context).size.width)
                        ],
                      )
                    ])),
            Flexible(
                flex: 1,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(color: Colors.red, child: Text('')),
                      _loadingElevationChart
                          ? CircularProgressIndicator(
                              color: CustomColors.accent,
                            )
                          : Flexible(
                              flex: 1,
                              child: charts.LineChart(_elevationData,
                                  /*behaviors: [
                  charts.LinePointHighlighter(
                  showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.none
                  ),
                ],*/
                                  primaryMeasureAxis: charts.NumericAxisSpec(
                                      tickProviderSpec:
                                          charts.StaticNumericTickProviderSpec(
                                    <charts.TickSpec<num>>[
                                      charts.TickSpec<num>(
                                          _elevationMin.toInt()),
                                      charts.TickSpec<num>(
                                          ((int.parse(_elevation) -
                                                      _elevationMin) ~/
                                                  3.03) +
                                              _elevationMin.toInt()),
                                      charts.TickSpec<num>(
                                          ((int.parse(_elevation) -
                                                      _elevationMin) ~/
                                                  1.51) +
                                              _elevationMin.toInt()),
                                      charts.TickSpec<num>(
                                          int.parse(_elevation)),
                                    ],
                                  )),
                                  selectionModels: [
                                    charts.SelectionModelConfig(
                                        type: charts.SelectionModelType.info,
                                        changedListener:
                                            (charts.SelectionModel model) {
                                          final selectedDatum =
                                              model.selectedDatum;
                                          if (selectedDatum.isNotEmpty &&
                                              this.mounted) {
                                            setState(() {
                                              _selectedPoint =
                                                  selectedDatum.first.datum;
                                            });
                                          }
                                        })
                                  ],
                                  domainAxis: charts.NumericAxisSpec(
                                      tickProviderSpec:
                                          charts.StaticNumericTickProviderSpec(
                                    <charts.TickSpec<num>>[
                                      charts.TickSpec<num>(0),
                                      charts.TickSpec<num>(
                                          _distance.indexOf('.') != -1
                                              ? double.parse(_distance) *
                                                  1000 ~/
                                                  3.03
                                              : double.parse(_distance) ~/
                                                  3.03),
                                      charts.TickSpec<num>(
                                          _distance.indexOf('.') != -1
                                              ? double.parse(_distance) *
                                                  1000 ~/
                                                  1.51
                                              : double.parse(_distance) ~/
                                                  1.51),
                                      charts.TickSpec<num>(
                                          _distance.indexOf('.') != -1
                                              ? double.parse(_distance) * 1000
                                              : int.parse(_distance)),
                                    ],
                                  )),
                                  animate: true))
                    ]))
          ]))
    ]));
  }

  @override
  bool get wantKeepAlive => true;
}
