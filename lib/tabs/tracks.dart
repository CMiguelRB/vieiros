import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:vieiros/components/tracks/bottom_sheet_actions.dart';
import 'package:vieiros/components/tracks/directory_list_element.dart';
import 'package:vieiros/components/tracks/track_info.dart';
import 'package:vieiros/components/tracks/track_list_element.dart';
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
import 'package:vieiros/model/track_list_entity.dart';

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
  List<TrackListEntity> _files = [];
  final TextEditingController _controller = TextEditingController(text: '');
  final _formKeyAddDirectory = GlobalKey<FormState>();
  BitmapDescriptor? _iconStart;
  BitmapDescriptor? _iconEnd;
  Directory? _currentDirectory;

  @override
  void initState() {
    super.initState();
    _loadCurrentPath();
    _loadFiles(true);
    _loadIconMarkers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadCurrentPath() async {
    _currentDirectory =
        Directory('${(await getApplicationDocumentsDirectory()).path}/tracks');
  }

  _loadFiles(bool init) {
    setState(() {
      _files = [];
      _files.add(
          TrackListEntity(name: 'loading', path: '/loading', isFile: true));
    });
    Future.delayed(Duration(milliseconds: init ? 400 : 0), () {
      List<TrackListEntity> files = [];
      getApplicationDocumentsDirectory().then((baseDir) {
        List<FileSystemEntity> entities = _currentDirectory!.listSync();
        entities.sort((FileSystemEntity a, FileSystemEntity b) =>
            a.path.compareTo(b.path));
        List<FileSystemEntity> directories = [];
        entities.removeWhere((element) {
          if (!FileSystemEntity.isFileSync(element.path)) {
            directories.add(element);
            return true;
          }
          return false;
        });
        directories.sort((FileSystemEntity a, FileSystemEntity b) =>
            a.path.compareTo(b.path));
        entities.insertAll(0, directories);
        for (FileSystemEntity entity in entities) {
          bool isFile = FileSystemEntity.isFileSync(entity.path);
          if (isFile) {
            String gpxString = (entity as File).readAsStringSync();
            Gpx gpx = GpxReader().fromString(gpxString);
            files.add(TrackListEntity(
                name: gpx.trks.first.name!, path: entity.path, isFile: true));
          } else {
            files.add(TrackListEntity(
                name: entity.path.split('/')[entity.path.split('/').length - 1],
                path: entity.path,
                isFile: false));
          }
        }
        if (mounted) {
          setState(() {
            _files = files;
          });
        }
      });
    });
  }

  Future<void> openFile(bool lightMode, double height) async {
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _files.insert(0,
            TrackListEntity(name: 'loading', path: '/loading', isFile: true));
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

  _setCurrentDirectory(String path) {
    setState(() {
      _currentDirectory = Directory(path);
    });
    _loadFiles(false);
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
    String directory =
        '${(await getApplicationDocumentsDirectory()).path}/tracks';
    for (var track in tracks) {
      String newPath = '$directory/${track.name.replaceAll(' ', '_')}.gpx';
      FilesHandler().writeFile(track.gpxString!, track.name, false);
      setState(() {
        if (_files
            .indexWhere((element) => element.path == newPath)
            .isNegative) {
          _files.insert(0,
              TrackListEntity(name: track.name, path: newPath, isFile: true));
        }
      });
    }
  }

  _unloadTrack(int index, bool showNotification) async {
    String? current = Preferences().get('currentTrack');
    TrackListEntity file = _files[index];
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
    TrackListEntity file = _files.removeAt(index);
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
    _loadFiles(false);
  }

  _clearValue() {
    _controller.clear();
    _loadFiles(false);
  }

  void addFileOrDirectory(bool lightMode) {
    _showBottomSheet(_fileManagerContent(lightMode));
  }

  _showTrackInfo(int index, bool lightMode, double height) async {
    TrackListEntity file = _files.elementAt(index);

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
          "action": () => _showDeleteDialog(index, true)
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
      "tracks_create_directory": {
        "icon": Icons.create_new_folder_outlined,
        "action": () => _addDirectoryModal(lightMode)
      }
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

  Widget _directoryManagerContent(int index, bool lightMode) {
    Map<String, Map<String, dynamic>> actions = {
      "common_rename": {
        "icon": Icons.drive_file_rename_outline,
        "action": () => _showRenameDirectoryModal(index, lightMode)
      },
      "common_delete": {
        "icon": Icons.delete,
        "action": () => _deleteDirectory(index)
      }
    };

    return Ink(
        height: 180,
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        color:
        lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Column(children: [
          Text(I18n.translate('common_edit'),
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          BottomSheetActions(actions: actions, lightMode: lightMode)
        ]));
  }

  _addDirectoryModal(bool lightMode) {
    Navigator.of(context).pop();
    String name = '';
    VieirosDialog().inputDialog(
        context,
        'common_name',
        {
          'common_ok': () => _addDirectory(name),
          'common_cancel': () => Navigator.pop(context, '')
        },
        form: Form(
            key: _formKeyAddDirectory,
            child: VieirosTextInput(
              lightMode: lightMode,
              hintText: 'common_name',
              onChanged: (value) => {name = value},
            )));
  }

  _addDirectory(String name) {
    Navigator.pop(context, '');
    Directory newDirectory = Directory('${_currentDirectory!.path}/$name');
    newDirectory.createSync();
    _loadFiles(false);
  }

  _moveFile(String directory, TrackListEntity trackListEntity){
    File(trackListEntity.path!).renameSync('$directory/${trackListEntity.name}.gpx');
    _loadFiles(false);
  }

  _showDirectoryActions(int index, bool lightMode){
    _showBottomSheet(_directoryManagerContent(index, lightMode));
  }

  _showRenameDirectoryModal(int index, bool lightMode){
    Navigator.pop(context, '');
    String name = '';
    VieirosDialog().inputDialog(
        context,
        'common_name',
        {
          'common_ok': () => _renameDirectory(index, name),
          'common_cancel': () => Navigator.pop(context, '')
        },
        form: Form(
            key: _formKeyAddDirectory,
            child: VieirosTextInput(
              lightMode: lightMode,
              hintText: 'common_name',
              onChanged: (value) => {name = value},
            )));
  }

  _renameDirectory(index, name){
    Navigator.pop(context, '');
    Directory directory = Directory(_files[index].path!);
    directory.renameSync('${directory.parent.path}/$name');
    _loadFiles(false);
  }

  _deleteDirectory(int index){
    _showDeleteDialog(index, false);
  }

  Future<bool> navigateUp() async {
    //TODO: move files & directories
    //TODO: drag directories
    //TODO: global search
    //TODO: accept tracks one by one
    if(_currentDirectory!.parent.path != (await getApplicationDocumentsDirectory()).path){
      setState(() {
        _currentDirectory = _currentDirectory!.parent;
      });
      _loadFiles(false);
      return false;
    }else{
      return true;
    }
  }

  _shareFile(int index) {
    Navigator.of(context).pop();
    Share.shareFiles([_files[index].path!], text: _files[index].name);
  }

  _showDeleteDialog(int index, isTrack) {
    Navigator.of(context).pop();
    VieirosDialog().infoDialog(
      context,
      isTrack ? 'tracks_delete_route' : 'tracks_delete_directory',
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
          onPressed: () => _showBottomSheet(_fileManagerContent(lightMode)),
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
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.only(
                            top: 8, left: 8, right: 8, bottom: 75),
                        itemCount: _files.length,
                        shrinkWrap: true,
                        itemBuilder: (itemContext, index) {
                          return _files[index].isFile
                              ? LongPressDraggable<TrackListEntity>(
                                  data: _files[index],
                                  feedback: Opacity(
                                      opacity: .75,
                                      child: TrackListElement(
                                        lightMode: lightMode,
                                        loadedTrack: widget.loadedTrack,
                                        trackListEntity: _files[index],
                                        index: index,
                                        navigate: _navigate,
                                        showTrackInfo: _showTrackInfo,
                                        unloadTrack: _unloadTrack,
                                      )),
                                  dragAnchorStrategy: pointerDragAnchorStrategy,
                                  child: TrackListElement(
                                    lightMode: lightMode,
                                    loadedTrack: widget.loadedTrack,
                                    trackListEntity: _files[index],
                                    index: index,
                                    navigate: _navigate,
                                    showTrackInfo: _showTrackInfo,
                                    unloadTrack: _unloadTrack,
                                  ))
                              : DragTarget<TrackListEntity>(
                                  builder:
                                      (context, candidateItems, rejectedItems) {
                                    if (candidateItems.isNotEmpty) {
                                      candidateItems.clear();
                                      candidateItems.add(_files[index]);
                                    }
                                    return DirectoryListElement(
                                        trackListEntity: _files[index],
                                        lightMode: lightMode,
                                        navigate: _setCurrentDirectory,
                                        highlighted: candidateItems.isNotEmpty,
                                        index: index,
                                        showDirectoryActions: _showDirectoryActions);
                                  },
                                  onAccept: (file) {
                                    _moveFile(_files[index].path!, file);
                                  },
                                );
                        }))
          ],
        )));
  }
}
