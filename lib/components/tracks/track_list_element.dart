import 'package:flutter/material.dart';
import 'package:vieiros/components/shimmer.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/model/track_list_entity.dart';
import 'package:vieiros/resources/custom_colors.dart';

class TrackListElement extends StatelessWidget {
  final bool lightMode;
  final TrackListEntity trackListEntity;
  final LoadedTrack loadedTrack;
  final int index;
  final Function showTrackInfo;
  final Function navigate;
  final Function unloadTrack;
  final Function? selectItem;
  final bool? selectionMode;
  final bool? selected;

  const TrackListElement({
    Key? key,
    required this.lightMode,
    required this.trackListEntity,
    required this.loadedTrack,
    required this.index,
    required this.showTrackInfo,
    required this.navigate,
    required this.unloadTrack,
    this.selectItem,
    this.selectionMode,
    this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool loadedElement = loadedTrack.path == trackListEntity.path;
    bool isSelected = selected != null && selected!;
    bool isSelectionMode = selectionMode != null && selectionMode!;
    double selectedIconWidth = 0;
    if (isSelected) {
      selectedIconWidth = 48;
    }
    Color backgroundColor;
    if(loadedElement && !isSelectionMode){
      backgroundColor = lightMode ? CustomColors.trackBackgroundLight : CustomColors.trackBackgroundDark;
    }else if(isSelected){
      backgroundColor = lightMode ? CustomColors.trackBackgroundLight : CustomColors.trackBackgroundDark;
    }else{
      backgroundColor = Colors.black12;
    }
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: () => selectItem != null ? selectItem!(index) : {},
          onTap: () => selectionMode != null && selectionMode! ? selectItem!(index) : navigate(index),
          key: Key(trackListEntity.path!),
          child: trackListEntity.path == '/loading'
              ? Shimmer.fromColors(
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
                  ]))
              : Card(
                  elevation: 0,
                  color: backgroundColor,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width - 48,
                          child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                            SizedBox(width: 48, child: Row(
                              mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                              children: [
                              AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: selectedIconWidth,
                                  curve: Curves.fastOutSlowIn,
                                  child: isSelected ? const Icon(Icons.check_circle) : const SizedBox()),
                              AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: loadedElement && !isSelectionMode ? 48 : 0,
                                  curve: Curves.fastOutSlowIn,
                                  child: loadedElement && !isSelectionMode
                                      ? IconButton(onPressed: () => unloadTrack(index, true), icon: const Icon(Icons.landscape))
                                      : const SizedBox()
                              )

                            ])),
                            Expanded(child: Text(trackListEntity.name,  maxLines: 1, overflow: TextOverflow.ellipsis)),
                            //Todo move feature
                            //Todo Save animatedListError
                            //Todo animatedList side animation
                            AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: !isSelectionMode ? 1 : 0,
                                child: !isSelectionMode ? IconButton(
                                alignment: Alignment.centerRight,
                                onPressed: () => showTrackInfo(index, lightMode, MediaQuery.of(context).size.height),
                                icon: const Icon(Icons.more_vert)):const SizedBox(height: 48,))
                          ])))),
        ));
  }
}
