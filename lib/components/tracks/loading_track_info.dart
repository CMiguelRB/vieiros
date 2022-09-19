import 'package:flutter/material.dart';
import 'package:vieiros/components/shimmer.dart';
import 'package:vieiros/components/tracks/track_info_track_altitude.dart';
import 'package:vieiros/components/tracks/track_info_track_distance.dart';
import 'package:vieiros/components/tracks/track_info_track_name.dart';
import 'package:vieiros/components/tracks/track_info_track_time.dart';
import 'package:vieiros/resources/custom_colors.dart';

class LoadingTrackInfo extends StatelessWidget {
  final bool lightMode;

  const LoadingTrackInfo({Key? key, required this.lightMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Color highlightColor = lightMode ? CustomColors.background : CustomColors.backgroundDark;
    Color baseColor = lightMode ? CustomColors.faintedFaintedAccent : CustomColors.trackBackgroundDark;
    return Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
      Shimmer.fromColors(
          highlightColor: highlightColor,
          baseColor: baseColor,
          child: TrackInfoTrackName(lightMode: lightMode, trackName: '')),
      Expanded(
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: width,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Shimmer.fromColors(
                    highlightColor: highlightColor,
                    baseColor: baseColor,
                    child: Container(color: CustomColors.background)))),
      ),
      Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, mainAxisSize: MainAxisSize.max, children: [
                Shimmer.fromColors(
                    highlightColor: highlightColor,
                    baseColor: baseColor,
                    child: TrackInfoTrackDistance(lightMode: lightMode, distance: 0,)),
                Shimmer.fromColors(
                    highlightColor: highlightColor,
                    baseColor: baseColor,
                    child: TrackInfoTrackTime(lightMode: lightMode, totalTime: '', initTime: null))
              ]),
              Shimmer.fromColors(
                  highlightColor: highlightColor,
                  baseColor: baseColor,
                  child: TrackInfoTrackAltitude(lightMode: lightMode, altitudeGain: '', altitudeMin: '', altitudeTop: ''))
            ],
          ))
    ]);
  }
}
