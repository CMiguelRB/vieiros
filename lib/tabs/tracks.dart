import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:xml/xml.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
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
  Tracks({Key? key, required this.toTabIndex, required this.prefs, required this.currentTrack, required this.loadedTrack, required this.clearTrack}) : super(key: key);

  TracksState createState() => TracksState();
}

class TracksState extends State<Tracks> {
  List<GpxFile> _files = [];

  loadPrefs() async {
    String? jsonString = widget.prefs.getString('files');
    jsonString = jsonString != null ? jsonString : '[]';
    List<GpxFile> files = json
        .decode(jsonString)
        .map<GpxFile>((file) => GpxFile.fromJson(file))
        .toList();
    for(var i = 0;i<files.length; i++){
      String? path = files[i].path;
      bool exists = false;
      if(path != null)
        exists = await File(path).exists();
      if(!exists){
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
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: const Text('Not a valid gpx file'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Ok'),
                child: const Text('Ok'),
              ),
            ],
          ),
        );
        return;
      }
      setState(() {
        for (var i = 0; i < _files.length; i++) {
          if (_files[i].path == result.files.single.path) {
            return;
          }
        }
        String? path = result.files.single.path;
        if (path == null) return;
        final xmlFile = new File(path);
        Gpx gpx = GpxReader().fromString(
            XmlDocument.parse(xmlFile.readAsStringSync()).toXmlString());
        String? name = gpx.trks[0].name;
        if (name == null) name = result.files.single.name;
        _files.add(GpxFile(name: name, path: result.files.single.path));
        widget.prefs.setString('files', jsonEncode(_files));
      });
    }
  }

  removeFile(context, index) async {
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
      if(path != null){
        File deleteFile = new File(path);
        deleteFile.delete();
      }
      Navigator.pop(context, 'OK');
    });
  }

  navigate(index) async {
    String? path = _files[index].path;
    if (path == null) return;
    widget.prefs.setString('currentTrack', path);
    widget.toTabIndex(1);
  }

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(8),
            itemCount: _files.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return InkWell(
                child: Card(
                    elevation: 0,
                    color: Colors.black12,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                                child: Text(_files[index].name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                            IconButton(
                                onPressed: () => showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        content: const Text('You sure?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context, 'Cancel'),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                removeFile(context, index),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    ),
                                icon: Icon(Icons.delete))
                          ]
                        ))),
                onTap: () => navigate(index),
              );
            }
          )
        )
      ],
    ));
  }
}
