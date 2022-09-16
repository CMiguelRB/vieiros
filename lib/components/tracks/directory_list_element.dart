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
  final Function? selectItem;
  final bool? selectionMode;
  final bool? selected;

  const DirectoryListElement({
    Key? key,
    required this.lightMode,
    required this.trackListEntity,
    required this.loadedTrack,
    required this.index,
    required this.navigate,
    required this.showDirectoryActions,
    this.selectItem,
    this.selectionMode,
    this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool loadedElement = loadedTrack.path != null ? loadedTrack.path!.contains(trackListEntity.path!) : false;
    bool isSelected = selected != null && selected!;
    bool isSelectionMode = selectionMode != null && selectionMode!;
    double selectedIconWidth = 0;
    if (isSelected) {
      selectedIconWidth = 48;
    }
    Color backgroundColor;
    if (loadedElement && selectionMode != null && !selectionMode!) {
      backgroundColor = lightMode ? CustomColors.trackBackgroundLight : CustomColors.trackBackgroundDark;
    } else if (isSelected) {
      backgroundColor = lightMode ? CustomColors.trackBackgroundLight : CustomColors.trackBackgroundDark;
    } else {
      backgroundColor = lightMode ? CustomColors.background : CustomColors.backgroundDark;
    }
    return InkWell(
      onLongPress: () => selectItem != null ? selectItem!(index) : {},
      onTap: () => isSelectionMode ? selectItem!(index) : navigate(trackListEntity.path!),
      key: Key(trackListEntity.path!),
      child: Card(
          elevation: 2,
          color: backgroundColor,
          surfaceTintColor: Colors.transparent,
          child: Padding(
              padding: const EdgeInsets.only( right: 8, top: 10, bottom: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: selectedIconWidth,
                    curve: Curves.fastOutSlowIn,
                    child: isSelected
                        ? const Icon(Icons.check_circle)
                        : const SizedBox(
                            width: 48,
                          )),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isSelected ? 0 : 48,
                    curve: Curves.fastOutSlowIn,
                    child: !isSelected ? const Icon(Icons.folder) : const SizedBox(width: 48,)),
                Expanded(child: Text(trackListEntity.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: !isSelectionMode ? 1 : 0,
              child: !isSelectionMode ?IconButton(
                    alignment: Alignment.centerRight, onPressed: () => showDirectoryActions(index, lightMode), icon: const Icon(Icons.more_vert)):const SizedBox(height: 48))
              ]))),
    );
  }
}
