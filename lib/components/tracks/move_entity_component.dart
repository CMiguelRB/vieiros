import 'package:flutter/material.dart';
import 'package:vieiros/components/tracks/bottom_sheet_actions.dart';
import 'package:vieiros/resources/custom_colors.dart';

class MoveEntityComponent extends StatefulWidget {
  final Map<String, Map<String, dynamic>> actions;
  final bool lightMode;
  final Function setMoveDirectory;
  final String rootPath;

  const MoveEntityComponent({Key? key, required this.actions, required this.lightMode,required this.rootPath, required this.setMoveDirectory}) : super(key: key);

  @override
  MoveEntityComponentState createState() => MoveEntityComponentState();
}

class MoveEntityComponentState extends State<MoveEntityComponent>{
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * .9,
        color: widget.lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Column(
          children: [Expanded(child: Container()), BottomSheetActions(actions: widget.actions, lightMode: widget.lightMode, loading: false)],
        ));
  }

}
