import 'package:flutter/material.dart';
import 'package:vieiros/model/track_list_entity.dart';

class MoveListElement extends StatelessWidget {
  final bool lightMode;
  final TrackListEntity trackListEntity;
  final Function setMoveDirectory;

  const MoveListElement({super.key, required this.lightMode, required this.trackListEntity, required this.setMoveDirectory});

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setMoveDirectory(trackListEntity.path!, true),
          key: Key(trackListEntity.path!),
          child: Card(
              elevation: 0,
              color: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Container(
                    height: 48, alignment: Alignment.centerLeft, child: Text(trackListEntity.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
              )),
        ));
  }
}
