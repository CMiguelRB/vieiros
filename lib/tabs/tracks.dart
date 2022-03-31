import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:vieiros/components/vieiros_dialog.dart';
import 'package:vieiros/components/vieiros_notification.dart';
import 'package:vieiros/components/vieiros_text_input.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:vieiros/utils/files_handler.dart';
import 'package:vieiros/utils/preferences.dart';
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
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: true);
    if (result != null) {
      if (result.isSinglePick) {
        _addFile(result.files.single);
      } else {
        for(var i = 0; i<result.files.length; i++){
          _addFile(result.files.elementAt(i));
        }
      }
    }
  }

  void _addFile(PlatformFile file) async {
    if (file.name
            .split('.')[file.name.split('.').length - 1] !=
        'gpx') {
      VieirosNotification().showNotification(
          context, 'tracks_file_validation_error', NotificationType.error);
      return;
    }
    for (var i = 0; i < _files.length; i++) {
      if (_files[i].path == file.path) return;
    }
    String? path = file.path;
    final xmlFile = File(path!);
    String gpxString =
        XmlDocument.parse(xmlFile.readAsStringSync()).toXmlString();
    Gpx gpx = GpxReader().fromString(gpxString);
    String? name = gpx.trks[0].name;
    name ??= file.name;
    String directory = (await getApplicationDocumentsDirectory()).path;
    String newPath = directory + '/' + name.replaceAll(' ', '_') + '.gpx';
    FilesHandler().writeFile(
        XmlDocument.parse(xmlFile.readAsStringSync()).toXmlString(),
        name,
        false);
    setState(() {
      if (_files.indexWhere((element) => element.path == newPath).isNegative) {
        _files.add(GpxFile(name: name!, path: newPath));
      }
    });
  }

  void openFileFromIntent(String gpxStringFile) async {
    Gpx gpx = GpxReader().fromString(gpxStringFile);
    String name = gpx.trks[0].name!;
    String? path = await FilesHandler().writeFile(gpxStringFile, name, false);
    setState(() {
      if (path != null &&
          _files.indexWhere((element) => element.path == path).isNegative) {
        _files.add(GpxFile(name: name, path: path));
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
    //_showDisclaimer();
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

  @override
  Widget build(BuildContext context) {
    bool lightMode = Provider.of<ThemeProvider>(context).isLightMode;
    return SafeArea(
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
                    onPressed:
                        _controller.value.text == '' ? null : _clearValue))),
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
                            color: _loadedElement
                                ? (lightMode
                                    ? CustomColors.trackBackgroundLight
                                    : CustomColors.trackBackgroundDark)
                                : Colors.black12,
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
                                                  _unloadTrack(index, true),
                                              icon: const Icon(Icons.landscape))
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
                                                    'common_ok': () =>
                                                        _removeFile(
                                                            context, index),
                                                    'common_cancel': () =>
                                                        Navigator.pop(
                                                            context, '')
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
