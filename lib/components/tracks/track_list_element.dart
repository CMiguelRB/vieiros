import 'package:flutter/material.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/model/track_list_entity.dart';
import 'package:vieiros/resources/custom_colors.dart';

class TrackListElement extends StatelessWidget{

  final bool lightMode;
  final TrackListEntity trackListEntity;
  final LoadedTrack loadedTrack;
  final int index;
  final Function showTrackInfo;
  final Function navigate;
  final Function unloadTrack;

  const TrackListElement({Key? key, required this.lightMode, required this.trackListEntity, required this.loadedTrack, required this.index, required this.showTrackInfo, required this.navigate, required this.unloadTrack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool loadedElement =
        loadedTrack.path == trackListEntity.path;
    return Material(color: Colors.transparent, child: InkWell(
        onTap: () => navigate(index),
        key: Key(trackListEntity.path!),
        child: Card(
            elevation: 0,
            color: loadedElement
                ? (lightMode
                ? CustomColors
                .trackBackgroundLight
                : CustomColors
                .trackBackgroundDark)
                : Colors.black12,
            child: Padding(
                padding: EdgeInsets.only(
                    left: loadedElement ? 0 : 16,
                    right: 8),
                child: SizedBox(width: 200, child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                          children: [
                      trackListEntity.path ==
                          '/loading'
                          ? SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(
                            color: lightMode
                                ? Colors.black
                                : Colors
                                .white,
                            strokeWidth: 2,
                          ))
                          : (loadedElement
                          ? IconButton(
                          onPressed: () =>
                              unloadTrack(
                                  index,
                                  true),
                          icon: const Icon(
                              Icons
                                  .landscape))
                          : Container()),
                      Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                              trackListEntity.path ==
                                  '/loading'
                                  ? ''
                                  : trackListEntity
                                  .name,
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis)),
                      trackListEntity.path ==
                          '/loading'
                          ? const SizedBox(
                          width: 50,
                          height: 50)
                          : IconButton(
                          alignment: Alignment
                              .centerRight,
                          onPressed: () =>
                              showTrackInfo(
                                  index,
                                  lightMode,
                                  MediaQuery.of(
                                      context)
                                      .size
                                      .height),
                          icon: const Icon(
                              Icons
                                  .more_vert))
                    ])))),
        ));
  }

}