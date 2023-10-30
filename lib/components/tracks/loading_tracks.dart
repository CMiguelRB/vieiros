import 'package:flutter/material.dart';
import 'package:vieiros/components/shimmer.dart';
import 'package:vieiros/resources/custom_colors.dart';

class LoadingTracks extends StatelessWidget {
  final bool lightMode;

  const LoadingTracks({super.key, required this.lightMode});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        highlightColor: lightMode ? CustomColors.background : CustomColors.backgroundDark,
        baseColor: lightMode ? CustomColors.faintedFaintedAccent : CustomColors.subText,
        child: Column(children: [
          Container(
            height: 48,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12))),
            margin: const EdgeInsets.only(bottom: 8, top: 4, left: 4, right: 4),
          ),
          Container(
            height: 48,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12))),
            margin: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
          ),
          Container(
            height: 48,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12))),
            margin: const EdgeInsets.only(left: 4, right: 4),
          )
        ]));
  }
}
