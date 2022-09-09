import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:vieiros/components/tracks/bottom_sheet_actions.dart';
import 'package:vieiros/components/tracks/directory_list_element.dart';
import 'package:vieiros/components/tracks/move_entity_component.dart';
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

  const Tracks({Key? key, required this.toTabIndex, required this.currentTrack, required this.loadedTrack, required this.clearTrack})
      : super(key: key);

  @override
  TracksState createState() => TracksState();
}

class TracksState extends State<Tracks> {
  List<TrackListEntity> _files = [];
  final TextEditingController _controller = TextEditingController(text: '');
  final _trackInfoKey = GlobalKey<TrackInfoState>();
  final _formKeyAddDirectory = GlobalKey<FormState>();
  FocusNode? _searchFocusNode;
  BitmapDescriptor? _iconStart;
  BitmapDescriptor? _iconEnd;
  Directory? _currentDirectory;
  String? _rootPath;
  List<Track> _trackList = [];
  int _currentTrackIndex = 0;
  String _moveDestinationPath = '';
  String _sortDirection = 'asc';
  double _backButtonWidth = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentPath();
    _loadFiles(init: true);
    _loadIconMarkers();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _searchFocusNode!.dispose();
  }

  _loadCurrentPath() async {
    String? directoryPrefs = Preferences().get('current_directory');
    String rootPath = '${(await getApplicationDocumentsDirectory()).path}/tracks';
    Directory? currentDirectory;
    if (directoryPrefs != '') {
      currentDirectory = Directory(directoryPrefs!);
    } else {
      currentDirectory = Directory(rootPath);
    }
    Preferences().set('current_directory', currentDirectory.path);
    setState(() {
      _rootPath = rootPath;
      _currentDirectory = currentDirectory;
    });
  }

  _loadFiles({bool? init, String? searchValue}) {
    setState(() {
      _files = [];
      _files.add(TrackListEntity(name: 'loading', path: '/loading', isFile: true));
    });
    Future.delayed(Duration(milliseconds: (init != null && init == true) ? 400 : 0), () {
      List<TrackListEntity> files = [];

      List<FileSystemEntity> entities = _currentDirectory!.listSync();
      for (FileSystemEntity entity in entities) {
        bool isFile = FileSystemEntity.isFileSync(entity.path);
        if (isFile) {
          String gpxString = (entity as File).readAsStringSync();
          Gpx gpx = GpxReader().fromString(gpxString);
          if (searchValue == null ||
              searchValue == '' ||
              (searchValue != '' && gpx.trks.first.name!.toLowerCase().contains(searchValue.toLowerCase()))) {
            files.add(TrackListEntity(name: gpx.trks.first.name!, path: entity.path, isFile: true));
          }
        } else {
          files.add(TrackListEntity(name: entity.path.split('/')[entity.path.split('/').length - 1], path: entity.path, isFile: false));
        }
      }
      //DO this with files, not entities
      files = _filesSorter(files: files, searchValue: searchValue);
      if (mounted) {
        setState(() {
          _files = files;
          if (_currentDirectory!.path != _rootPath) {
            _backButtonWidth = 50;
          } else {
            _backButtonWidth = 0;
          }
        });
      }
    });
  }

  List<TrackListEntity> _filesSorter({required List<TrackListEntity> files, String? searchValue}) {
    files.sort((TrackListEntity a, TrackListEntity b) => _sortDirection == 'asc' ? a.path!.compareTo(b.path!) : b.path!.compareTo(a.path!));
    List<TrackListEntity> directories = [];
    files.removeWhere((element) {
      if (!element.isFile) {
        directories.add(element);
        return true;
      }
      return false;
    });
    if (searchValue == null || searchValue == '') {
      directories.sort((TrackListEntity a, TrackListEntity b) => _sortDirection == 'asc' ? a.path!.compareTo(b.path!) : b.path!.compareTo(a.path!));
      files.insertAll(0, directories);
    }
    return files;
  }

  _setSortDirection({required String sortDirection}) {
    setState(() {
      _sortDirection = sortDirection;
    });
    _loadFiles();
  }

  _setCurrentDirectory(String path) {
    Preferences().set('current_directory', path);
    setState(() {
      _currentDirectory = Directory(path);
    });
    _loadFiles(init: false);
  }

  Future<void> openFile(bool lightMode, double height) async {
    Navigator.pop(context);

    Timer(const Duration(milliseconds: 400), () {
      _showBottomSheet(_trackManagerContent(0, lightMode, height, true));
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true);

    if (result != null) {
      _addFiles(result.files, lightMode, height);
    } else {
      if (mounted) {
        Navigator.pop(context, '');
      }
    }
  }

  void _addFiles(List<PlatformFile> files, bool lightMode, double height) async {
    bool plural = files.length > 1;

    files.removeWhere((file) => file.name.split('.')[file.name.split('.').length - 1] != 'gpx');

    for (int i = 0; i < files.length; i++) {
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

    if (files.isEmpty && mounted) {
      Navigator.pop(context, '');
      VieirosNotification()
          .showNotification(context, plural ? 'tracks_file_validation_error_plural' : 'tracks_file_validation_error', NotificationType.error);
      return;
    }

    List<Track> tracks = [];
    for (var file in files) {
      Track track = Track();
      tracks.add(await track.loadTrack(file.path));
    }
    setState(() {
      _trackList = tracks;
      if (_trackInfoKey.currentState != null && _trackInfoKey.currentState!.mounted) {
        _trackInfoKey.currentState!.setTrackList(tracks: tracks, index: 0, fromSave: false);
      }
      //_showBottomSheet(_trackManagerContent(0, lightMode, height, true));
    });
  }

  void _saveFiles(List<Track> tracks) async {
    String directory = _currentDirectory!.path;
    List<TrackListEntity> files = _files;
    List<Track> trackList = _trackList;
    for (int i = 0; i < tracks.length; i++) {
      String newPath = '$directory/${tracks[i].name.replaceAll(' ', '_')}.gpx';
      FilesHandler().writeFile(tracks[i].gpxString!, tracks[i].name, false);
      files.add(TrackListEntity(name: tracks[i].name, path: newPath, isFile: true));
      trackList.removeWhere((element) => element.path == tracks[i].path);
      tracks.removeAt(i);
      i--;
    }

    List<TrackListEntity> directories = [];
    for (int i = 0; i < files.length; i++) {
      if (!files[i].isFile) {
        directories.add(files[i]);
      }
    }

    files = _filesSorter(files: files);

    setState(() {
      _files = files;
      _trackList = trackList;
      if (_currentTrackIndex != 0) {
        _currentTrackIndex -= 1;
      }
    });
    if (_trackInfoKey.currentState != null) {
      _trackInfoKey.currentState!.setTrackList(tracks: _trackList, index: _currentTrackIndex, fromSave: true);
    }
    if (trackList.isEmpty) {
      Navigator.pop(context);
      _currentTrackIndex = 0;
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
      VieirosNotification().showNotification(context, 'tracks_unloaded', NotificationType.info);
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
    BitmapDescriptor futureIconStart = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(100, 100)), 'assets/loaded_pin.png');
    BitmapDescriptor futureIconEnd =
        await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(100, 100)), 'assets/loaded_pin_end.png');
    setState(() {
      _iconStart = futureIconStart;
      _iconEnd = futureIconEnd;
    });
  }

  _clearValue() {
    _controller.clear();
    _searchFocusNode!.unfocus();
    _loadFiles();
  }

  void addFileOrDirectory(bool lightMode) {
    _showBottomSheet(_fileManagerContent(lightMode));
  }

  _showTrackInfo(int index, bool lightMode, double height) async {
    TrackListEntity file = _files.elementAt(index);

    Track track = Track();
    await track.loadTrack(file.path);

    setState(() {
      _trackList = [track];
    });
    _showBottomSheet(_trackManagerContent(index, lightMode, height, false));
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

  Widget _trackManagerContent(int index, bool lightMode, double? height, bool isNewTrack) {
    Map<String, Map<String, dynamic>> actions = {};

    if (isNewTrack) {
      if (_trackList.length > 1) {
        actions.addAll({
          "common_save_all": {
            "icon": Icons.save_outlined,
            "action": () => _saveFiles([..._trackList])
          }
        });
      }
      actions.addAll({
        "common_save": {
          "icon": Icons.save_outlined,
          "action": () => _saveFiles([_trackList[_currentTrackIndex]])
        },
        "common_cancel": {"icon": Icons.close, "action": () => Navigator.pop(context)}
      });
    } else {
      actions = {
        "common_share": {"icon": Icons.share, "action": () => _shareFile(index)},
        "common_move": {
          "icon": Icons.drive_file_move_outline,
          "action": () => _showBottomSheet(_moveManagerContent(lightMode: lightMode, trackListEntity: _files[index]))
        },
        "common_delete": {"icon": Icons.delete, "action": () => _showDeleteDialog(index, true)}
      };
    }

    return TrackInfo(
      key: _trackInfoKey,
      lightMode: lightMode,
      actions: actions,
      tracks: _trackList,
      iconStart: _iconStart!,
      iconEnd: _iconEnd!,
      onIndexChange: _onIndexChange,
    );
  }

  void _onIndexChange({required int value}) {
    _currentTrackIndex = value;
  }

  Widget _fileManagerContent(bool lightMode) {
    Map<String, Map<String, dynamic>> actions = {
      "tracks_add_file": {"icon": Icons.file_download, "action": () => openFile(lightMode, MediaQuery.of(context).size.height)},
      "tracks_create_directory": {"icon": Icons.create_new_folder_outlined, "action": () => _addDirectoryModal(lightMode)}
    };

    return Ink(
        height: 180,
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        color: lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Column(children: [
          Text(I18n.translate('common_add'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          BottomSheetActions(actions: actions, lightMode: lightMode)
        ]));
  }

  Widget _directoryManagerContent(int index, bool lightMode) {
    Map<String, Map<String, dynamic>> actions = {
      "common_rename": {"icon": Icons.drive_file_rename_outline, "action": () => _showRenameDirectoryModal(index, lightMode)},
      "common_move": {
        "icon": Icons.drive_file_move_outline,
        "action": () => _showBottomSheet(_moveManagerContent(lightMode: lightMode, trackListEntity: _files[index]))
      },
      "common_delete": {"icon": Icons.delete, "action": () => _deleteDirectory(index)}
    };

    return Ink(
        height: 180,
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        color: lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Column(children: [
          Text(I18n.translate('common_edit'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          BottomSheetActions(actions: actions, lightMode: lightMode)
        ]));
  }

  _moveManagerContent({required bool lightMode, required TrackListEntity trackListEntity}) {
    Navigator.pop(context, '');

    _setMoveDirectory(_rootPath!);
    Map<String, Map<String, dynamic>> actions = {
      "common_move": {"icon": Icons.check, "action": () => _moveFileAction(_moveDestinationPath, trackListEntity)},
      "common_cancel": {"icon": Icons.close, "action": () => _cancelMove()}
    };
    return MoveEntityComponent(
      actions: actions,
      lightMode: lightMode,
      setMoveDirectory: _setMoveDirectory,
      rootPath: _rootPath!,
      moveElement: trackListEntity,
      filesSorter: _filesSorter,
    );
  }

  _setMoveDirectory(String directoryPath) async {
    setState(() {
      _moveDestinationPath = directoryPath;
    });
  }

  _addDirectoryModal(bool lightMode) {
    Navigator.of(context).pop();
    String name = '';
    VieirosDialog().inputDialog(context, 'common_name', {'common_ok': () => _addDirectory(name), 'common_cancel': () => _cancelMove},
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
    _loadFiles();
  }

  _moveFileAction(String directory, TrackListEntity trackListEntity) {
    if (directory != '') {
      _moveFile(directory, trackListEntity);
      _cancelMove();
    }
  }

  _cancelMove() {
    Navigator.pop(context, '');
    setState(() {
      _moveDestinationPath = '';
    });
  }

  _moveFile(String directory, TrackListEntity trackListEntity) {
    if (trackListEntity.isFile) {
      File(trackListEntity.path!).renameSync('$directory/${trackListEntity.name}.gpx');
    } else {
      if (directory != trackListEntity.path) {
        Directory(trackListEntity.path!).renameSync('$directory/${trackListEntity.name}');
      }
    }
    _loadFiles();
  }

  _showDirectoryActions(int index, bool lightMode) {
    _showBottomSheet(_directoryManagerContent(index, lightMode));
  }

  _showRenameDirectoryModal(int index, bool lightMode) {
    Navigator.pop(context, '');
    String name = '';
    VieirosDialog()
        .inputDialog(context, 'common_name', {'common_ok': () => _renameDirectory(index, name), 'common_cancel': () => Navigator.pop(context, '')},
            form: Form(
                key: _formKeyAddDirectory,
                child: VieirosTextInput(
                  lightMode: lightMode,
                  hintText: 'common_name',
                  onChanged: (value) => {name = value},
                )));
  }

  _renameDirectory(index, name) {
    Navigator.pop(context, '');
    Directory directory = Directory(_files[index].path!);
    directory.renameSync('${directory.parent.path}/$name');
    _loadFiles();
  }

  _deleteDirectory(int index) {
    _showDeleteDialog(index, false);
  }

  Future<bool> navigateUp() async {
    if (_currentDirectory!.parent.path != _rootPath!.substring(0, _rootPath!.length - 7)) {
      Preferences().set('current_directory', _currentDirectory!.parent.path);
      setState(() {
        _currentDirectory = _currentDirectory!.parent;
      });
      _loadFiles();
      return false;
    } else {
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
      {'common_ok': () => _removeFile(context, index), 'common_cancel': () => Navigator.pop(context, '')},
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
          onPressed: () => _showBottomSheet(_fileManagerContent(lightMode)),
          child: const Icon(Icons.add),
        ),
        body: GestureDetector(
            onTap: () => _searchFocusNode!.unfocus(),
            child: SafeArea(
                child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.all(12),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: _backButtonWidth,
                            curve: Curves.fastOutSlowIn,
                            child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                enableFeedback: _currentDirectory != null && _currentDirectory!.parent.path != _rootPath,
                                onPressed: () => navigateUp()),
                          ),
                          Expanded(
                              child: VieirosTextInput(
                                  lightMode: lightMode,
                                  hintText: I18n.translate('tracks_search_hint'),
                                  onChanged: (text) => _loadFiles(searchValue: text),
                                  controller: _controller,
                                  focusNode: _searchFocusNode,
                                  suffix: IconButton(
                                      icon: Icon(_controller.value.text == '' ? Icons.search : Icons.clear,
                                          color: lightMode ? CustomColors.subText : CustomColors.subTextDark),
                                      onPressed: _controller.value.text == '' ? null : _clearValue))),
                          IconButton(
                              icon: const Icon(Icons.sort),
                              onPressed: () => _setSortDirection(sortDirection: _sortDirection == 'asc' ? 'desc' : 'asc'))
                        ])),
                Expanded(
                    child: _files.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            child: Text(I18n.translate('tracks_background_tip'),
                                style: TextStyle(color: lightMode ? CustomColors.subText : CustomColors.subTextDark)))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 75),
                            itemCount: _files.length,
                            shrinkWrap: true,
                            itemBuilder: (itemContext, index) {
                              return LongPressDraggable<TrackListEntity>(
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
                                  child: _files[index].isFile
                                      ? TrackListElement(
                                          lightMode: lightMode,
                                          loadedTrack: widget.loadedTrack,
                                          trackListEntity: _files[index],
                                          index: index,
                                          navigate: _navigate,
                                          showTrackInfo: _showTrackInfo,
                                          unloadTrack: _unloadTrack,
                                        )
                                      : DragTarget<TrackListEntity>(
                                          builder: (context, candidateItems, rejectedItems) {
                                            return DirectoryListElement(
                                                trackListEntity: _files[index],
                                                loadedTrack: widget.loadedTrack,
                                                lightMode: lightMode,
                                                navigate: _setCurrentDirectory,
                                                highlighted: candidateItems.isNotEmpty,
                                                index: index,
                                                showDirectoryActions: _showDirectoryActions);
                                          },
                                          onAccept: (file) {
                                            _moveFile(_files[index].path!, file);
                                          },
                                        ));
                            }))
              ],
            ))));
  }
}
