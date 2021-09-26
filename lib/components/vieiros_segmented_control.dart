import 'package:flutter/cupertino.dart';

class VieirosSegmentedControl extends StatelessWidget{

  final Map<int,Widget> tabMap;
  final int slideState;
  final Function onValueChanged;

  const VieirosSegmentedControl({Key? key, required this.tabMap, required this.slideState, required this.onValueChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 20),
        child: CupertinoSlidingSegmentedControl(
            children: tabMap,
            groupValue: slideState,
            onValueChanged: (value) => onValueChanged(value)));
  }

}