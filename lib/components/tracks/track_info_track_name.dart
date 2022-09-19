import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';

class TrackInfoTrackName extends StatelessWidget {
  final String trackName;
  final bool lightMode;

  const TrackInfoTrackName({Key? key, required this.trackName, required this.lightMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Color background = lightMode ? CustomColors.background : CustomColors.backgroundDark;

    return Container(
        margin: const EdgeInsets.all(20),
        height: 55,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: background, borderRadius: const BorderRadius.all(Radius.circular(16))),
        child: Text(
          trackName,
          maxLines: 2,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ));
  }
}
