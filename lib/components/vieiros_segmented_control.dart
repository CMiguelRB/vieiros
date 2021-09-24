import 'package:flutter/cupertino.dart';

class VieirosSegmentedControl extends StatelessWidget{

  final Map<int,Widget> tabMap;
  final int slideState;
  final Function onValueChanged;

  VieirosSegmentedControl({required this.tabMap, required this.slideState, required this.onValueChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 20),
        child: CupertinoSlidingSegmentedControl(
            children: tabMap,
            groupValue: slideState,
            onValueChanged: (value) => onValueChanged(value)));
  }

}