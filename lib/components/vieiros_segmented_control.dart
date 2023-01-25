import 'package:flutter/material.dart';
import 'package:vieiros/tabs/info.dart';

class VieirosSegmentedControl extends StatelessWidget {
  final List<ButtonSegment> tabMap;
  final Set<InfoDisplay> infoDisplaySet;
  final Function onValueChanged;

  const VieirosSegmentedControl({Key? key, required this.tabMap, required this.infoDisplaySet, required this.onValueChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: SegmentedButton(
            segments: tabMap, selected: infoDisplaySet, multiSelectionEnabled: false, showSelectedIcon: false,  onSelectionChanged: (value) => onValueChanged(value)));
  }
}
