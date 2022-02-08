import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vieiros/components/vieiros_dialog.dart';
import 'package:vieiros/components/vieiros_notification.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:vieiros/utils/files_handler.dart';
import 'package:xml/xml.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpx/gpx.dart';
import 'package:vieiros/model/gpx_file.dart';

class Tracks extends StatefulWidget {
  final Function toTabIndex;
  final Function clearTrack;
  final CurrentTrack currentTrack;
  final SharedPreferences prefs;
  final LoadedTrack loadedTrack;

  const Tracks(
      {Key? key,
      required this.toTabIndex,
      required this.prefs,
      required this.currentTrack,
      required this.loadedTrack,
      required this.clearTrack})
      : super(key: key);

  @override
  TracksState createState() => TracksState();
}

class TracksState extends State<Tracks> {
  List<GpxFile> _files = [];
  _loadPrefs() async {
    String? jsonString = widget.prefs.getString('files');
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
    }
    setState(() {
      _files = files;
    });
  }

  Future<void> openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      if (result.files.single.name
              .split('.')[result.files.single.name.split('.').length - 1] !=
          'gpx') {
        VieirosNotification().showNotification(
            context, 'tracks_file_validation_error', NotificationType.error);
        return;
      }
      for (var i = 0; i < _files.length; i++) {
        if (_files[i].path == result.files.single.path) return;
      }
      String? path = result.files.single.path;
      final xmlFile = File(path!);
      Gpx gpx = GpxReader().fromString(
          XmlDocument.parse(xmlFile.readAsStringSync()).toXmlString());
      setState(() {
        String? name = gpx.trks[0].name;
        name ??= result.files.single.name;
        _files.add(GpxFile(name: name, path: result.files.single.path));
        widget.prefs.setString('files', jsonEncode(_files));
      });
    }
  }

  void openFileFromIntent(String gpxStringFile) async{
    Gpx gpx = GpxReader().fromString(gpxStringFile);
    String name = gpx.trks[0].name!;
    String? path = await FilesHandler().writeFile(gpxStringFile, name, widget.prefs, false);
    setState(() {
      if(path != null) _files.add(GpxFile(name: name, path: path));
    });
  }

  _unloadTrack(index) async {
    setState(() {
      GpxFile file = _files[index];
      String? current = widget.prefs.getString('currentTrack');
      if (current == file.path) {
        widget.prefs.remove('currentTrack');
        widget.clearTrack();
        widget.loadedTrack.clear();
      }
      VieirosNotification()
          .showNotification(context, 'tracks_unloaded', NotificationType.info);
    });
  }

  _removeFile(context, index) async {
    setState(() {
      GpxFile file = _files.removeAt(index);
      widget.prefs.setString('files', jsonEncode(_files));
      String? current = widget.prefs.getString('currentTrack');
      if (current == file.path) {
        widget.prefs.remove('currentTrack');
        widget.clearTrack();
        widget.loadedTrack.clear();
      }
      String? path = file.path;
      if (path != null) {
        File deleteFile = File(path);
        deleteFile.delete();
      }
      Navigator.pop(context, I18n.translate("common_ok"));
    });
  }

  _navigate(index) async {
    String? path = _files[index].path;
    if (path == null) return;
    widget.prefs.setString('currentTrack', path);
    widget.toTabIndex(1);
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool lightMode = Provider.of<ThemeProvider>(context).isLightMode;
    return SafeArea(
        child: Column(
      children: [
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
                    padding: const EdgeInsets.all(8),
                    itemCount: _files.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      bool _loadedElement =
                          widget.loadedTrack.path == _files[index].path;
                      return InkWell(
                        child: Card(
                            elevation: 0,
                            color: Colors.black12,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: _loadedElement ? 0 : 16, right: 8),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      _loadedElement
                                          ? IconButton(
                                              onPressed: () =>
                                                  _unloadTrack(index),
                                              icon: const Icon(Icons.clear))
                                          : const Text(''),
                                      Flexible(
                                          fit: FlexFit.tight,
                                          child: Text(_files[index].name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis)),
                                      IconButton(
                                          alignment: Alignment.centerRight,
                                          onPressed: () =>
                                              VieirosDialog().infoDialog(
                                                  context,
                                                  'tracks_delete_route',
                                                  {
                                                    'common_cancel': () =>
                                                        Navigator.pop(
                                                            context, ''),
                                                    'common_ok': () =>
                                                        _removeFile(
                                                            context, index)
                                                  },
                                                  bodyTag: 'common_confirm'),
                                          icon: const Icon(Icons.delete))
                                    ]))),
                        onTap: () => _navigate(index),
                      );
                    }))
      ],
    ));
  }
}