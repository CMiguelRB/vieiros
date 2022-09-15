import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vieiros/components/tracks/bottom_sheet_actions.dart';
import 'package:vieiros/components/tracks/move_list_element.dart';
import 'package:vieiros/model/track_list_entity.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class MoveEntityComponent extends StatefulWidget {
  final Map<String, Map<String, dynamic>> actions;
  final bool lightMode;
  final Function setMoveDirectory;
  final String rootPath;
  final Function filesSorter;
  final TrackListEntity moveElement;

  const MoveEntityComponent(
      {Key? key,
      required this.actions,
      required this.lightMode,
      required this.rootPath,
      required this.setMoveDirectory,
      required this.filesSorter,
      required this.moveElement})
      : super(key: key);

  @override
  MoveEntityComponentState createState() => MoveEntityComponentState();
}

class MoveEntityComponentState extends State<MoveEntityComponent> {
  GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();
  List<TrackListEntity> _moveListEntities = [];
  String _currentDirectory = '';
  bool _hideMove = false;
  double _backButtonWidth = 0;

  @override
  void initState() {
    super.initState();
    _setMoveDirectory(widget.rootPath, false);
  }

  _setMoveDirectory(String directoryPath, bool callParent) async {
    if (_animatedListKey.currentState != null) {
      _animatedListKey = GlobalKey<AnimatedListState>();
    }
    bool hideMove = false;
    List<FileSystemEntity> fileSystemEntities = Directory(directoryPath).listSync();
    fileSystemEntities.removeWhere((entity) => FileSystemEntity.isFileSync(entity.path));
    List<TrackListEntity> moveListEntities = [];
    for (int i = 0; i < fileSystemEntities.length; i++) {
      TrackListEntity trackListEntity = TrackListEntity(
          name: fileSystemEntities[i].path.split('/')[fileSystemEntities[i].path.split('/').length - 1],
          path: fileSystemEntities[i].path,
          isFile: false);
      if (!widget.moveElement.path!.contains(directoryPath) || widget.moveElement.path! != trackListEntity.path) {
        moveListEntities.add(trackListEntity);
      }
    }
    moveListEntities = widget.filesSorter(files: moveListEntities);
    if (!widget.moveElement.isFile) {
      String pat = Directory(widget.moveElement.path!).parent.path;
      hideMove = directoryPath == widget.rootPath && _moveListEntities.isEmpty && widget.rootPath == pat;
    }
    setState(() {
      _moveListEntities = moveListEntities;
      _currentDirectory = directoryPath;
      _hideMove = hideMove;
      _backButtonWidth = directoryPath != widget.rootPath ? 50 : 0;
    });
    if (callParent == true) {
      widget.setMoveDirectory(directoryPath);
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_animatedListKey.currentState != null) {
      for (int i = 0; i < moveListEntities.length; i++) {
        _animatedListKey.currentState!.insertItem(i, duration: const Duration(milliseconds: 100));
      }
    }
  }

  _goBack() {
    Directory directory = Directory(_currentDirectory);
    _setMoveDirectory(directory.parent.path, true);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, dynamic>> actions = {...widget.actions};
    if (_hideMove) {
      actions.removeWhere((key, value) => key == 'common_move');
    }
    return Container(
        height: MediaQuery.of(context).size.height * .9,
        color: widget.lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: widget.lightMode ? CustomColors.faintedFaintedAccent : CustomColors.trackBackgroundDark,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
              child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _backButtonWidth,
                    curve: Curves.fastOutSlowIn,
                    height: 50,
                    child: _backButtonWidth != 0 ? IconButton(icon: const Icon(Icons.arrow_back), enableFeedback: _backButtonWidth != 0, onPressed: () => _goBack()):Container()),
                Expanded(
                  child: Container(margin: EdgeInsets.symmetric(horizontal: _backButtonWidth != 0 ? 0 : 20),
                    child: Text(
                  I18n.translate('tracks_select_move_destination'),
                  style: const TextStyle(fontSize: 16),
                )))
              ]),
            ),
            Expanded(
                child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    decoration: BoxDecoration(
                        color: widget.lightMode ? CustomColors.faintedFaintedAccent : CustomColors.trackBackgroundDark,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8))),
                    child: _hideMove
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: MediaQuery.of(context).size.width * .8,
                                          margin: const EdgeInsets.only(bottom: 10),
                                          child: Text(I18n.translate('tracks_move_forbidden'), maxLines: 3, textAlign: TextAlign.center)),
                                      const Icon(Icons.cancel_outlined, size: 80, color: Colors.black54)
                                    ])
                              ])
                        : AnimatedList(
                            key: _animatedListKey,
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 4),
                            initialItemCount: 0,
                            shrinkWrap: true,
                            itemBuilder: (itemContext, index, animation) {
                              return SlideTransition(
                                  position: animation.drive(Tween(begin: const Offset(0, 1), end: const Offset(0, 0))), child: MoveListElement(
                                  lightMode: widget.lightMode,
                                  trackListEntity: _moveListEntities.elementAt(index),
                                  setMoveDirectory: _setMoveDirectory));
                            }))),
            Container(
                margin: const EdgeInsets.only(bottom: 30), child: BottomSheetActions(actions: actions, lightMode: widget.lightMode, loading: false))
          ],
        ));
  }
}
