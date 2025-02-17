import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vieiros/components/tracks/bottom_sheet_actions.dart';
import 'package:vieiros/components/tracks/directory_list_element.dart';
import 'package:vieiros/components/tracks/file_manager_bar.dart';
import 'package:vieiros/components/tracks/loading_tracks.dart';
import 'package:vieiros/components/tracks/move_entity_component.dart';
import 'package:vieiros/components/tracks/search_track_bar.dart';
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
import 'package:vieiros/utils/permission_handler.dart';
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

  const Tracks({super.key, required this.toTabIndex, required this.currentTrack, required this.loadedTrack, required this.clearTrack});

  @override
  TracksState createState() => TracksState();
}

class TracksState extends State<Tracks> {
  List<TrackListEntity> _files = [];
  final TextEditingController _controller = TextEditingController(text: '');
  final _trackInfoKey = GlobalKey<TrackInfoState>();
  final _formKeyAddDirectory = GlobalKey<FormState>();
  GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();
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
  bool _loadingFiles = true;
  String? _searchValue;
  bool _add = false;
  final List<int> _selectedItems = [];
  bool _selectionMode = false;
  Offset _trackListOffset = const Offset(1, 0);

  @override
  void initState() {
    super.initState();
    _loadFiles(init: true);
    _loadIconMarkers();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _searchFocusNode!.dispose();
  }

  _loadFiles({bool? init, String? searchValue}) async {
    if (_loadingFiles != true) {
      setState(() {
        _loadingFiles = true;
      });
    }
    String? rootPath;
    Directory? currentDirectory = _currentDirectory;
    if (init != null && init == true) {
      rootPath = '${(await getApplicationDocumentsDirectory()).path}/tracks';
      String? directoryPrefs = Preferences().get('current_directory');
      if (directoryPrefs != '') {
        currentDirectory = Directory(directoryPrefs!);
      } else {
        currentDirectory = Directory(rootPath);
      }
      Preferences().set('current_directory', currentDirectory.path);
    }

    List<TrackListEntity> files = [];
    List<FileSystemEntity> entities = currentDirectory!.listSync(recursive: searchValue != null && searchValue != '');
    for (int i = 0; i < entities.length; i++) {
      if (entities[i] is File) {
        Preferences prefs = Preferences();
        String? name = prefs.get(entities[i].path);
        if (name == null) {
          Gpx gpx = GpxReader().fromString((entities[i] as File).readAsStringSync());
          name = gpx.trks.first.name!;
          prefs.set(entities[i].path, name);
        }
        if (searchValue == null || searchValue == '' || (searchValue != '' && name.toLowerCase().contains(searchValue.toLowerCase()))) {
          files.add(TrackListEntity(name: name, path: entities[i].path, isFile: true));
        }
      } else {
        files.add(TrackListEntity(name: entities[i].path.split('/')[entities[i].path.split('/').length - 1], path: entities[i].path, isFile: false));
      }
    }
    files = _filesSorter(files: files, searchValue: searchValue);
    if (mounted) {
      setState(() {
        _searchValue = searchValue;
        _files = files;
        if (rootPath != null) {
          _rootPath = rootPath;
        }
        if (currentDirectory != null) {
          _currentDirectory = currentDirectory;
        }
        if (_currentDirectory!.path != _rootPath) {
          _backButtonWidth = 40;
        } else {
          _backButtonWidth = 0;
        }
        _loadingFiles = false;
      });
      await _generateList(files);
    }
  }

  _generateList(List<TrackListEntity> files) async {
    setState(() {
      _add = false;
    });
    if (_animatedListKey.currentState != null) {
      _animatedListKey = GlobalKey<AnimatedListState>();
    }
    await Future.delayed(const Duration(milliseconds: 150));
    if (_animatedListKey.currentState != null && _add == false) {
      setState(() {
        _add = true;
      });
      for (int i = 0; i < files.length; i++) {
        _animatedListKey.currentState!.insertItem(i, duration: const Duration(milliseconds: 100));
      }
    }
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
    List<TrackListEntity> files = [..._files];
    files = _filesSorter(files: files);
    setState(() {
      _files = files;
    });
  }

  _setCurrentDirectory(String path) {
    Preferences().set('current_directory', path);
    setState(() {
      _currentDirectory = Directory(path);
      _trackListOffset = const Offset(1, 0);
    });
    _loadFiles(init: false);
  }

  Future<void> openFile(bool lightMode, double height) async {
    Navigator.pop(context);
    setState(() {
      _loadingFiles = true;
    });
    bool hasPermission = await PermissionHandler().handleWritePermission();

    if (hasPermission) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true);

      if (result != null) {
        _addFiles(result.files, lightMode, height);
      } else {
        if (mounted) {
          setState(() {
            _loadingFiles = false;
          });
          _loadFiles();
        }
      }
    }
  }

  void _addFiles(List<PlatformFile> files, bool lightMode, double height) async {
    files.removeWhere((file) => file.name.split('.')[file.name.split('.').length - 1] != 'gpx');
    List<Track> tracks = await _preProcessFiles(files: files);
    _buildTrackInfo(tracks: tracks, lightMode: lightMode, height: height);
  }

  Future<List<Track>> _preProcessFiles({required List<PlatformFile> files}) async {
    List<Track> tracks = [];
    for (int i = 0; i < files.length; i++) {
      String? path = files[i].path;
      Track track = await Track().loadTrack(path);
      Iterable<TrackListEntity> exists = _files.where((element) => element.name == track.name);
      if (exists.isEmpty) {
        tracks.add(track);
      }
    }
    return tracks;
  }

  _buildTrackInfo({required List<Track> tracks, required bool lightMode, required double height}) {
    bool plural = tracks.length > 1;
    if (tracks.isEmpty && mounted) {
      VieirosNotification()
          .showNotification(context, plural ? 'tracks_file_validation_error_plural' : 'tracks_file_validation_error', NotificationType.error);
      setState(() {
        _loadingFiles = false;
      });
      _loadFiles();
      return;
    }

    setState(() {
      _trackList = tracks;
      _loadingFiles = false;
      if (_trackInfoKey.currentState != null && _trackInfoKey.currentState!.mounted) {
        _trackInfoKey.currentState!.setTrackList(tracks: tracks, index: 0, fromSave: false);
      }
    });

    _showBottomSheet(_trackManagerContent(0, lightMode, height, true));
  }

  void _saveFiles(List<Track> tracks) async {
    if (_animatedListKey.currentState != null) {}
    String directory = _currentDirectory!.path;
    List<TrackListEntity> files = [..._files];
    List<Track> trackList = _trackList;
    for (int i = 0; i < tracks.length; i++) {
      String newPath = '$directory/${tracks[i].name.replaceAll(' ', '_')}.gpx';
      FilesHandler().writeFile(tracks[i].gpxString!, tracks[i].name, newPath, false);
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
    await _generateList(files);
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

  _removeFile(context, List<int> indexList) async {
    bool loadedRemoved = false;
    List<TrackListEntity> files = [..._files];
    for (var i = 0; i < indexList.length; i++) {
      int fileIndex = indexList[i] - i;
      TrackListEntity file = files.removeAt(fileIndex);
      _animatedListKey.currentState!.removeItem(fileIndex, (context, i) => Container(), duration: const Duration(milliseconds: 100));
      await FilesHandler().removeFile(file.path);
      String? current = Preferences().get('currentTrack');
      if (current == file.path) {
        Preferences().remove('currentTrack');
        loadedRemoved = true;
      }
    }
    setState(() {
      _files = files;
      _selectedItems.clear();
      _selectionMode = false;
      if (loadedRemoved) {
        widget.clearTrack();
        widget.loadedTrack.clear();
      }
    });
    Navigator.pop(context, I18n.translate("common_ok"));
  }

  _navigate(index) async {
    String? path = _files[index].path;
    if (path == null || path == '/loading') return;
    await Preferences().set('currentTrack', path);
    widget.toTabIndex(1);
  }

  void _loadIconMarkers() async {
    BitmapDescriptor futureIconStart = await BitmapDescriptor.asset(const ImageConfiguration(), 'assets/loaded_pin.png', width: 25);
    BitmapDescriptor futureIconEnd =
        await BitmapDescriptor.asset(const ImageConfiguration(), 'assets/loaded_pin_end.png', width: 25);
    setState(() {
      _iconStart = futureIconStart;
      _iconEnd = futureIconEnd;
    });
  }

  _clearValue() {
    _controller.clear();
    _searchFocusNode!.unfocus();
    _loadFiles();
    setState(() {
      _searchValue = null;
    });
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
    if (_selectionMode) {
      setState(() {
        _selectionMode = false;
        _selectedItems.clear();
      });
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
        "common_cancel": {
          "icon": Icons.close,
          "action": () => {Navigator.pop(context, ''), _loadFiles()}
        }
      });
    } else {
      actions = {
        "common_share": {"icon": Icons.share, "action": () => _shareFile(index)},
        "common_directions": {"icon": Icons.directions, "action": () => _getDirections(index)},
        "common_move": {
          "icon": Icons.drive_file_move_outline,
          "action": () => _showBottomSheet(_moveManagerContent(lightMode: lightMode, trackListEntity: [_files[index]], popContext: true))
        },
        "common_delete": {
          "icon": Icons.delete,
          "action": () => _showDeleteDialog([index], true)
        }
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
        height: 192,
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
        "action": () => _showBottomSheet(_moveManagerContent(lightMode: lightMode, trackListEntity: [_files[index]], popContext: true))
      },
      "common_delete": {"icon": Icons.delete, "action": () => _deleteDirectory(index)}
    };

    return Ink(
        height: 192,
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        color: lightMode ? CustomColors.background : CustomColors.backgroundDark,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(I18n.translate('common_edit'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              BottomSheetActions(actions: actions, lightMode: lightMode)
            ]));
  }

  _moveManagerContent({required bool lightMode, required List<TrackListEntity> trackListEntity, required bool popContext}) {
    if (popContext) {
      Navigator.pop(context, '');
    }
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
                  initialValue: _files[index].name,
                  hintText: 'common_name',
                  onChanged: (value) => {name = value},
                )));
  }

  _renameDirectory(index, name) {
    Navigator.pop(context, '');
    String path = _files[index].path!;
    Directory directory = Directory(path);
    String newPath = '${directory.parent.path}/$name';
    directory.renameSync(newPath);
    List<TrackListEntity> files = [..._files];
    files[index].name = name;
    files[index].path = newPath;
    List<MapEntry<String, dynamic>> preferences = Preferences().getAll();
    for (int i = 0; i < preferences.length; i++) {
      if (preferences[i].key.contains(path)) {
        String pat = preferences[i].key;
        String? name = preferences[i].value;
        Preferences().remove(path);
        pat = pat.replaceAll(path, newPath);
        Preferences().set(pat, name!);
        if (widget.loadedTrack.path != null) {
          Preferences().remove('currentTrack');
          widget.clearTrack();
          widget.loadedTrack.clear();
        }
      }
    }
    setState(() {
      _files = files;
    });
  }

  _deleteDirectory(int index) {
    _showDeleteDialog([index], false);
  }

  _setMoveDirectory(String directoryPath) async {
    setState(() {
      _moveDestinationPath = directoryPath;
    });
  }

  _addDirectoryModal(bool lightMode) {
    Navigator.of(context).pop();
    String name = '';
    VieirosDialog().inputDialog(context, 'common_name', {'common_ok': () => _addDirectory(name), 'common_cancel': () => Navigator.pop(context, '')},
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
    String path = '${_currentDirectory!.path}/$name';
    Directory newDirectory = Directory(path);
    newDirectory.createSync();
    List<TrackListEntity> files = _files;
    files.add(TrackListEntity(name: name, path: path, isFile: false));
    files = _filesSorter(files: files);
    setState(() {
      _files = files;
    });
    if (_animatedListKey.currentState != null) {
      _animatedListKey.currentState!.insertItem(0, duration: const Duration(milliseconds: 100));
    }
  }

  _moveFileAction(String directory, List<TrackListEntity> trackListEntity) {
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

  _moveFile(String directory, List<TrackListEntity> trackListEntity) {
    List<TrackListEntity> files = [..._files];
    for (int i = 0; i < trackListEntity.length; i++) {
      if (trackListEntity[i].isFile) {
        String newPath = '$directory/${trackListEntity[i].name}.gpx';
        File(trackListEntity[i].path!).renameSync(newPath);
        Preferences().remove(trackListEntity[i].path!);
        Preferences().set(newPath, trackListEntity[i].name);
        if (widget.loadedTrack.path == trackListEntity[i].path) {
          Preferences().set('currentTrack', newPath);
          widget.loadedTrack.loadTrack(newPath);
        }
      } else {
        if (directory != trackListEntity[i].path) {
          Directory(trackListEntity[i].path!).renameSync('$directory/${trackListEntity[i].name}');
        }
      }
      files.removeWhere((file) => file.path == trackListEntity[i].path);
    }
    setState(() {
      _files = files;
    });
    _generateList(files);
  }

  Future<bool> navigateUp() async {
    if (_currentDirectory!.parent.path != _rootPath!.substring(0, _rootPath!.length - 7)) {
      Preferences().set('current_directory', _currentDirectory!.parent.path);
      setState(() {
        _currentDirectory = _currentDirectory!.parent;
        _trackListOffset = const Offset(-1, 0);
      });
      _loadFiles();
      return false;
    } else {
      return true;
    }
  }

  _shareFile(int index) {
    Navigator.of(context).pop();
    Share.shareXFiles([XFile(_files[index].path!)], text: _files[index].name);
  }

  _showDeleteDialog(List<int> indexList, bool? isTrack) {
    if (isTrack != null) {
      Navigator.of(context).pop();
    }
    VieirosDialog().infoDialog(
      context,
      isTrack == null ? 'tracks_delete_selection' : (isTrack ? 'tracks_delete_route' : 'tracks_delete_directory'),
      {
        'common_ok': () => _removeFile(context, indexList),
        'common_cancel': () => {
              Navigator.pop(context, ''),
              setState(() {
                _selectionMode = false;
                _selectedItems.clear();
              })
            }
      },
      bodyTag: 'common_confirm',
    );
  }

  _onSearchChanged(String text) async {
    if (_searchValue == text) {
      return;
    }
    _loadFiles(searchValue: text);
  }

  _selectItem(int index) {
    setState(() {
      _selectedItems.contains(index) ? _selectedItems.remove(index) : _selectedItems.add(index);
      _selectedItems.sort();
      _selectionMode = true;
    });
  }

  _moveSelection(bool lightMode) {
    List<TrackListEntity> files = [];
    for (int i = 0; i < _selectedItems.length; i++) {
      files.add(_files[_selectedItems[i]]);
    }
    _showBottomSheet(_moveManagerContent(lightMode: lightMode, trackListEntity: files, popContext: false));
  }

  _cancelSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedItems.clear();
    });
  }

  _getDirections(index) async {
    Gpx gpx;
    try{
      gpx = GpxReader().fromString(File(_files[index].path!).readAsStringSync());
    }catch(e){
      VieirosNotification().showNotification(context, 'tracks_open_maps_error', NotificationType.error);
      throw 'Unreadable file';
    }
    Uri uri = Uri.parse('${'geo:0,0?q=${gpx.trks.first.trksegs.first.trkpts.first.lat}'},${gpx.trks.first.trksegs.first.trkpts.first.lon}');
    bool launch = await canLaunchUrl(uri);
    if (launch) {
      await launchUrl(uri);
    } else {
      if(mounted){
        VieirosNotification().showNotification(context, 'tracks_open_maps_error', NotificationType.error);
      }
     throw 'Could not launch ${uri.toString()}';
    }
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
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    margin: const EdgeInsets.all(12),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FileManagerBar(
                            lightMode: lightMode,
                            selectionMode: _selectionMode,
                            cancelSelectionMode: _cancelSelectionMode,
                            moveSelection: _moveSelection,
                            showDeleteDialog: () => _showDeleteDialog(_selectedItems, null),
                          ),
                          SearchTrackBar(
                              lightMode: lightMode,
                              selectionMode: _selectionMode,
                              sortDirection: _sortDirection,
                              backButtonWidth: _backButtonWidth,
                              currentDirectory: _currentDirectory,
                              rootPath: _rootPath,
                              navigateUp: navigateUp,
                              onSearchChanged: _onSearchChanged,
                              setSortDirection: _setSortDirection,
                              clearValue: _clearValue,
                              controller: _controller,
                              searchFocusNode: _searchFocusNode)
                        ])),
                Expanded(
                    child: _files.isEmpty && !_loadingFiles
                        ? Container(
                            alignment: Alignment.center,
                            child: Text(I18n.translate('tracks_background_tip'),
                                style: TextStyle(color: lightMode ? CustomColors.subText : CustomColors.subTextDark)))
                        : _loadingFiles
                            ? LoadingTracks(lightMode: lightMode)
                            : AnimatedList(
                                key: _animatedListKey,
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 75),
                                initialItemCount: 0,
                                shrinkWrap: true,
                                itemBuilder: (itemContext, index, animation) {
                                  return SlideTransition(
                                    position: animation.drive(Tween(begin: _trackListOffset, end: const Offset(0, 0))),
                                    child: _files[index].isFile
                                        ? TrackListElement(
                                            lightMode: lightMode,
                                            loadedTrack: widget.loadedTrack,
                                            trackListEntity: _files[index],
                                            index: index,
                                            navigate: _navigate,
                                            selectItem: _selectItem,
                                            selectionMode: _selectionMode,
                                            selected: _selectedItems.contains(index),
                                            showTrackInfo: _showTrackInfo,
                                            unloadTrack: _unloadTrack,
                                          )
                                        : DirectoryListElement(
                                            trackListEntity: _files[index],
                                            loadedTrack: widget.loadedTrack,
                                            lightMode: lightMode,
                                            navigate: _setCurrentDirectory,
                                            index: index,
                                            selectItem: _selectItem,
                                            selectionMode: _selectionMode,
                                            selected: _selectedItems.contains(index),
                                            showDirectoryActions: _showDirectoryActions),
                                  );
                                }))
              ],
            ))));
  }
}
