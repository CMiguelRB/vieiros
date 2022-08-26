import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:vieiros/components/tracks/bottom_sheet_actions.dart';
import 'package:vieiros/components/tracks/track_info.dart';
import 'package:vieiros/components/vieiros_dialog.dart';
import 'package:vieiros/components/vieiros_notification.dart';
import 'package:vieiros/components/vieiros_text_input.dart';
import 'package:vieiros/model/track.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:vieiros/utils/files_handler.dart';
import 'package:vieiros/utils/preferences.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/model/gpx_file.dart';

class Tracks extends StatefulWidget {
  final Function toTabIndex;
  final Function clearTrack;
  final CurrentTrack currentTrack;
  final LoadedTrack loadedTrack;

  const Tracks(
      {Key? key,
      required this.toTabIndex,
      required this.currentTrack,
      required this.loadedTrack,
      required this.clearTrack})
      : super(key: key);

  @override
  TracksState createState() => TracksState();
}

class TracksState extends State<Tracks> with WidgetsBindingObserver {
  List<GpxFile> _files = [];
  final TextEditingController _controller = TextEditingController(text: '');
  final ScrollController _scrollController = ScrollController();
  bool _showFAB = true;
  BitmapDescriptor? _iconStart;
  BitmapDescriptor? _iconEnd;

  @override
  void initState() {
    super.initState();
    _loadPrefs('');
    _loadIconMarkers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadPrefs(String value) async {
    String? jsonString = Preferences().get('files');
    jsonString = jsonString ?? '[]';
    List<GpxFile> files = json
        .decode(jsonString)
        .map<GpxFile>((file) => GpxFile.fromJson(file))
        .toList();
    for (var i = 0; i < files.length; i++) {
      String? path = files[i].path;
      bool exists = false;
      if (path != null) exists = await File(path).exists();
      if (!exists) {
        files.removeAt(i);
      }
      if (value != '' &&
          !files[i].name.toLowerCase().contains(value.toLowerCase())) {
        files.removeAt(i);
        i--;
      }
    }
    setState(() {
      _files = files;
    });
  }

  Future<void> openFile(bool lightMode, double height) async {
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _files.insert(0, GpxFile(name: 'loading', path: '/loading'));
      });
    });

    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: true);

    if (result != null) {
      _addFile(result.files, lightMode, height);
    }
    setState(() {
      _files.removeWhere((element) => element.path == '/loading');
    });
  }

  void _addFile(List<PlatformFile> files, bool lightMode, double height) async {
    Navigator.pop(context);
    bool plural = files.length > 1;

    files.removeWhere((file) =>
        file.name.split('.')[file.name.split('.').length - 1] != 'gpx');

    for (var i = 0; i < files.length; i++) {
      String? path = files[i].path;
      final xmlFile = File(path!);
      String gpxString = xmlFile.readAsStringSync();
      Gpx? gpx;
      try {
        gpx = GpxReader().fromString(gpxString);
      } catch (e) {
        files.removeAt(i);
        i--;
        break;
      }
      for (var file in _files) {
        if (file.name == gpx.trks.first.name!) {
          files.removeAt(i);
          i--;
          break;
        }
      }
    }

    if (files.isEmpty) {
      VieirosNotification().showNotification(
          context,
          plural
              ? 'tracks_file_validation_error_plural'
              : 'tracks_file_validation_error',
          NotificationType.error);
      return;
    }

    List<Track> tracks = [];
    for (var file in files) {
      Track track = Track();
      tracks.add(await track.loadTrack(file.path));
    }
    _showBottomSheet(_trackManagerContent(tracks, 0, lightMode, height, true));
  }

  void _saveFiles(List<Track> tracks) async {
    Navigator.pop(context);
    String directory = (await getApplicationDocumentsDirectory()).path;
    for (var track in tracks) {
      String newPath = '$directory/${track.name.replaceAll(' ', '_')}.gpx';
      FilesHandler().writeFile(track.gpxString!, track.name, false);
      setState(() {
        if (_files
            .indexWhere((element) => element.path == newPath)
            .isNegative) {
          _files.insert(0, GpxFile(name: track.name, path: newPath));
        }
      });
    }
  }

  _unloadTrack(int index, bool showNotification) async {
    String? current = Preferences().get('currentTrack');
    GpxFile file = _files[index];
    if (current == file.path) {
      await Preferences().remove('currentTrack');
    }
    setState(() {
      if (current == file.path) {
        widget.clearTrack();
        widget.loadedTrack.clear();
      }
    });
    if (showNotification) {
      if (!mounted) return;
      VieirosNotification()
          .showNotification(context, 'tracks_unloaded', NotificationType.info);
    }
  }

  _removeFile(context, index) async {
    GpxFile file = _files.removeAt(index);
    await Preferences().set('files', json.encode(_files));
    String? current = Preferences().get('currentTrack');
    if (current == file.path) {
      await Preferences().remove('currentTrack');
    }
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      setState(() {
        if (current == file.path) {
          widget.clearTrack();
          widget.loadedTrack.clear();
        }
        FilesHandler().removeFile(file.path);
        Navigator.pop(context, I18n.translate("common_ok"));
        if (!_showFAB && _scrollController.positions.isNotEmpty) {
          _showFAB = _scrollController.position.maxScrollExtent < 40;
        }
      });
    });
  }

  _navigate(index) async {
    String? path = _files[index].path;
    if (path == null) return;
    await Preferences().set('currentTrack', path);
    widget.toTabIndex(1);
  }

  void _loadIconMarkers() async {
    BitmapDescriptor futureIconStart = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        'assets/loaded_pin.png');
    BitmapDescriptor futureIconEnd = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        'assets/loaded_pin_end.png');
    setState(() {
      _iconStart = futureIconStart;
      _iconEnd = futureIconEnd;
    });
  }

  _onChanged(value) {
    _loadPrefs(_controller.value.text);
  }

  _clearValue() {
    _controller.clear();
    _loadPrefs(_controller.value.text);
  }

  void addFileOrDirectory(bool lightMode) {
    _showBottomSheet(_fileManagerContent(lightMode));
  }

  _showTrackInfo(int index, bool lightMode, double height) async {
    GpxFile file = _files.elementAt(index);

    Track track = Track();
    await track.loadTrack(file.path);

    _showBottomSheet(
        _trackManagerContent([track], index, lightMode, height, false));
  }

  _showBottomSheet(Widget content) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext context) {
          return content;
        });
  }

  Widget _trackManagerContent(List<Track> tracks, int index, bool lightMode,
      double? height, bool isNewTrack) {
    Map<String, Map<String, dynamic>> actions = {};

    if (isNewTrack) {
      actions = {
        "common_save": {
          "icon": Icons.save_outlined,
          "action": () => _saveFiles(tracks)
        },
        "common_cancel": {
          "icon": Icons.cancel_outlined,
          "action": () => Navigator.pop(context)
        }
      };
    } else {
      actions = {
        "common_share": {
          "icon": Icons.share,
          "action": () => _shareFile(index)
        },
        "common_delete": {
          "icon": Icons.delete,
          "action": () => _showDeleteDialog(index)
        }
      };
    }

    return TrackInfo(
        lightMode: lightMode,
        actions: actions,
        tracks: tracks,
        iconStart: _iconStart!,
        iconEnd: _iconEnd!);
  }

  Widget _fileManagerContent(bool lightMode) {
    Map<String, Map<String, dynamic>> actions = {
      "tracks_add_file": {
        "icon": Icons.file_download,
        "action": () => openFile(lightMode, MediaQuery.of(context).size.height)
      },
      /*"tracks_create_directory": {
        "icon": Icons.create_new_folder_outlined,
        "action": _addDirectory
      }*/
    };

    return Ink(
        height: 180,
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        color:
            lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Column(children: [
          Text(I18n.translate('common_add'),
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          BottomSheetActions(actions: actions, lightMode: lightMode)
        ]));
  }

  /*_addDirectory() {
    Navigator.of(context).pop();
    if (kDebugMode) {
      print('add directory');
    }
  }*/

  _shareFile(int index) {
    Navigator.of(context).pop();
    Share.shareFiles([_files[index].path!], text: _files[index].name);
  }

  _showDeleteDialog(int index) {
    Navigator.of(context).pop();
    VieirosDialog().infoDialog(
      context,
      'tracks_delete_route',
      {
        'common_ok': () => _removeFile(context, index),
        'common_cancel': () => Navigator.pop(context, '')
      },
      bodyTag: 'common_confirm',
    );
  }

  @override
  Widget build(BuildContext context) {
    bool lightMode = Provider.of<ThemeProvider>(context).isLightMode;
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _showFAB
            ? FloatingActionButton(
                heroTag: null,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0))),
                onPressed: () =>
                    _showBottomSheet(_fileManagerContent(lightMode)),
                child: const Icon(Icons.add),
              )
            : null,
        body: SafeArea(
            child: Column(
          children: [
            Container(
                margin: const EdgeInsets.all(12),
                child: VieirosTextInput(
                    lightMode: lightMode,
                    hintText: I18n.translate('tracks_search_hint'),
                    onChanged: _onChanged,
                    controller: _controller,
                    suffix: IconButton(
                        icon: Icon(
                            _controller.value.text == ''
                                ? Icons.search
                                : Icons.clear,
                            color: lightMode
                                ? CustomColors.subText
                                : CustomColors.subTextDark),
                        onPressed: _controller.value.text == ''
                            ? null
                            : _clearValue))),
            Expanded(
                child: _files.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        child: Text(I18n.translate('tracks_background_tip'),
                            style: TextStyle(
                                color: lightMode
                                    ? CustomColors.subText
                                    : CustomColors.subTextDark)))
                    : NotificationListener<ScrollUpdateNotification>(
                        onNotification: (notification) {
                          if (_showFAB && notification.metrics.pixels > 30) {
                            setState(() {
                              _showFAB = false;
                            });
                          }
                          if (!_showFAB && notification.metrics.pixels < 30) {
                            setState(() {
                              _showFAB = true;
                            });
                          }
                          return true;
                        },
                        child: ReorderableListView.builder(
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.only(
                              top: 8, left: 8, right: 8, bottom: 60),
                          itemCount: _files.length,
                          shrinkWrap: true,
                          scrollController: _scrollController,
                          itemBuilder: (itemContext, index) {
                            bool loadedElement =
                                widget.loadedTrack.path == _files[index].path;
                            return InkWell(
                              key: Key(_files[index].path!),
                              child: Card(
                                  elevation: 0,
                                  color: loadedElement
                                      ? (lightMode
                                          ? CustomColors.trackBackgroundLight
                                          : CustomColors.trackBackgroundDark)
                                      : Colors.black12,
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          left: loadedElement ? 0 : 16,
                                          right: 8),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            _files[index].path == '/loading'
                                                ? SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: lightMode
                                                          ? Colors.black
                                                          : Colors.white,
                                                      strokeWidth: 2,
                                                    ))
                                                : (loadedElement
                                                    ? IconButton(
                                                        onPressed: () =>
                                                            _unloadTrack(
                                                                index, true),
                                                        icon: const Icon(
                                                            Icons.landscape))
                                                    : Container()),
                                            Flexible(
                                                fit: FlexFit.tight,
                                                child: Text(
                                                    _files[index].path ==
                                                            '/loading'
                                                        ? ''
                                                        : _files[index].name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                            _files[index].path == '/loading'
                                                ? const SizedBox(
                                                    width: 50, height: 50)
                                                : IconButton(
                                                    alignment: Alignment
                                                        .centerRight,
                                                    onPressed: () =>
                                                        _showTrackInfo(
                                                            index,
                                                            lightMode,
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height),
                                                    icon: const Icon(
                                                        Icons.more_vert))
                                          ]))),
                              onTap: () => _navigate(index),
                            );
                          },
                          onReorder: (int oldIndex, int newIndex) {
                            GpxFile file = _files.removeAt(oldIndex);
                            if (oldIndex < newIndex) {
                              newIndex--;
                            }
                            _files.insert(newIndex, file);
                            setState(() {
                              _files = _files;
                            });
                            Preferences().set('files', json.encode(_files));
                          },
                        )))
          ],
        )));
  }
}
