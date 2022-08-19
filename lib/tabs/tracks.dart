import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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

class TracksState extends State<Tracks> {
  List<GpxFile> _files = [];
  final TextEditingController _controller = TextEditingController(text: '');

  final Set<Marker> _markers = {};

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

  Future<void> openFile() async {
    //Navigator.of(context).pop();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _files.insert(0, GpxFile(name: 'loading', path: '/loading'));
      });
    });

    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: true);
    if (result != null) {
      setState(() {
        _files.removeWhere((element) => element.path == '/loading');
      });
      if (result.isSinglePick) {
        _addFile(result.files.single);
      } else {
        for (var i = 0; i < result.files.length; i++) {
          _addFile(result.files.elementAt(i));
        }
      }
    } else {
      setState(() {
        _files.removeWhere((element) => element.path == '/loading');
      });
    }
  }

  void _addFile(PlatformFile file) async {
    if (file.name.split('.')[file.name.split('.').length - 1] != 'gpx') {
      VieirosNotification().showNotification(
          context, 'tracks_file_validation_error', NotificationType.error);
      return;
    }
    for (var i = 0; i < _files.length; i++) {
      if (_files[i].path == file.path) return;
    }
    String? path = file.path;
    final xmlFile = File(path!);
    String gpxString = xmlFile.readAsStringSync();
    Gpx gpx;
    try {
      gpx = GpxReader().fromString(gpxString);
    } catch (e) {
      VieirosNotification().showNotification(
          context, 'tracks_file_validation_error', NotificationType.error);
      return;
    }
    String? name = gpx.trks[0].name;
    name ??= file.name;
    String directory = (await getApplicationDocumentsDirectory()).path;
    String newPath = '$directory/${name.replaceAll(' ', '_')}.gpx';
    FilesHandler().writeFile(gpxString, name, false);
    setState(() {
      if (_files.indexWhere((element) => element.path == newPath).isNegative) {
        _files.insert(0, GpxFile(name: name!, path: newPath));
      }
    });
  }

  void openFileFromIntent(String gpxStringFile) async {
    Gpx gpx;
    try {
      gpx = GpxReader().fromString(gpxStringFile);
    } catch (e) {
      VieirosNotification().showNotification(
          context, 'tracks_file_validation_error', NotificationType.error);
      return;
    }
    String name = gpx.trks[0].name!;
    String? path = await FilesHandler().writeFile(gpxStringFile, name, false);
    setState(() {
      if (path != null &&
          _files.indexWhere((element) => element.path == path).isNegative) {
        _files.insert(0, GpxFile(name: name, path: path));
      }
    });
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
    setState(() {
      if (current == file.path) {
        widget.clearTrack();
        widget.loadedTrack.clear();
      }
      FilesHandler().removeFile(file.path);
      Navigator.pop(context, I18n.translate("common_ok"));
    });
  }

  _navigate(index) async {
    String? path = _files[index].path;
    if (path == null) return;
    await Preferences().set('currentTrack', path);
    widget.toTabIndex(1);
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs('');
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onChanged(value) {
    _loadPrefs(_controller.value.text);
  }

  _clearValue() {
    _controller.clear();
    _loadPrefs(_controller.value.text);
  }

  void addFileOrDirectory(bool lightMode) {
    _showBottomSheet('fileManager', 0, lightMode, null);
  }

  _showBottomSheet(
      String type, int index, bool lightMode, double? height) async {
    Widget content;

    if (type == 'fileManager') {
      content = _fileManagerContent(lightMode);
    } else {
      content = await _trackManagerContent(index, lightMode, height);
    }

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

  Future<Widget> _trackManagerContent(
      int index, bool lightMode, double? height) async {
    GpxFile file = _files.elementAt(index);

    Track track = await Track().loadTrack(file.path);

    double lat = track.gpx!.trks.first.trksegs.first.trkpts.first.lat!;
    double lon = track.gpx!.trks.first.trksegs.first.trkpts.first.lon!;

    Marker marker = Marker(
        markerId: const MarkerId('12345'),
        position: LatLng(lat, lon),
        icon: BitmapDescriptor.defaultMarker);
    setState(() {
      _markers.add(marker);
    });

    BitmapDescriptor iconStart = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        'assets/loaded_pin.png');
    BitmapDescriptor iconEnd = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        'assets/loaded_pin_end.png');

    return TrackInfo(
        lightMode: lightMode,
        actions: {
          "common_share": {
            "icon": Icons.share,
            "action": () => _shareFile(index)
          },
          "common_delete": {
            "icon": Icons.delete,
            "action": () => _showDeleteDialog(index)
          }
        },
        track: track,
      iconStart: iconStart,
      iconEnd: iconEnd,
    );
  }

  Widget _fileManagerContent(bool lightMode) {
    Map<String, Map<String, dynamic>> actions = {
      "tracks_add_file": {"icon": Icons.file_download, "action": openFile},
      "tracks_create_directory": {
        "icon": Icons.create_new_folder_outlined,
        "action": _addDirectory
      }
    };

    return Ink(
        height: 180,
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        color:
            lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Column(children:[
          Text(I18n.translate('common_add'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          BottomSheetActions(actions: actions, lightMode: lightMode)]));
  }

  _addDirectory() {
    Navigator.of(context).pop();
    if (kDebugMode) {
      print('add directory');
    }
  }

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
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          onPressed: () => openFile()/*addFileOrDirectory(lightMode)*/,
          child: const Icon(Icons.add),
        ),
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
                    : ReorderableListView.builder(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.all(8),
                        itemCount: _files.length,
                        shrinkWrap: true,
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
                                        left: loadedElement ? 0 : 16, right: 8),
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
                                                      _showBottomSheet(
                                                          'trackManager',
                                                          index,
                                                          lightMode,
                                                          MediaQuery.of(context)
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
                      ))
          ],
        )));
  }
}
