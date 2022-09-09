import 'package:flutter/material.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/model/track_list_entity.dart';
import 'package:vieiros/resources/custom_colors.dart';

class DirectoryListElement extends StatelessWidget {
  final bool lightMode;
  final TrackListEntity trackListEntity;
  final LoadedTrack loadedTrack;
  final int index;
  final Function navigate;
  final Function showDirectoryActions;
  final bool highlighted;

  const DirectoryListElement(
      {Key? key,
      required this.lightMode,
      required this.highlighted,
      required this.trackListEntity,
      required this.loadedTrack,
      required this.index,
      required this.navigate,
      required this.showDirectoryActions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool loadedElement = loadedTrack.path != null ? loadedTrack.path!.contains(trackListEntity.path!) : false;
    return InkWell(
        onTap: () => navigate(trackListEntity.path!),
        key: Key(trackListEntity.path!),
        child: Card(
            elevation: 2,
            color: highlighted
                ? (lightMode ? Colors.white : Colors.black)
                : (loadedElement
                    ? (lightMode ? CustomColors.trackBackgroundLight : CustomColors.trackBackgroundDark)
                    : (lightMode ? CustomColors.background : CustomColors.backgroundDark)),
            surfaceTintColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 8, top: 10, bottom: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                const SizedBox(width: 20, height: 20, child: Icon(Icons.folder)),
                Container(margin: const EdgeInsets.symmetric(horizontal: 10)),
                Expanded(child: Text(trackListEntity.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                IconButton(
                    alignment: Alignment.centerRight, onPressed: () => showDirectoryActions(index, lightMode), icon: const Icon(Icons.more_vert))
              ]),
            )));
  }
}
