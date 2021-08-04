import 'dart:convert';
import 'package:vieiros/model/current_track.dart';
import 'package:xml/xml.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpx/gpx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vieiros/model/gpx_file.dart';

class Tracks extends StatefulWidget {
  final Function toTabIndex;
  final CurrentTrack currentTrack;
  Tracks({Key? key, required this.toTabIndex, required this.currentTrack}) : super(key: key);

  TracksState createState() => TracksState();
}

class TracksState extends State<Tracks> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<GpxFile> _files = [];

  loadPrefs() async {
    //todo check if files exists on every start. If not, remove from list.
    final SharedPreferences prefs = await _prefs;
    String? jsonString = prefs.getString('files');
    jsonString = jsonString != null ? jsonString : '[]';
    List<GpxFile> files = json
        .decode(jsonString)
        .map<GpxFile>((file) => GpxFile.fromJson(file))
        .toList();
    setState(() {
      _files = files;
    });
  }

  Future<void> openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      print(result.files.single.name
          .split('.')[result.files.single.name.split('.').length - 1]);
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
      final SharedPreferences prefs = await _prefs;
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
        prefs.setString('files', jsonEncode(_files));
      });
    }
  }

  removeFile(context, index) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      GpxFile file = _files.removeAt(index);
      prefs.setString('files', jsonEncode(_files));
      String? current = prefs.getString('currentTrack');
      if (current == file.path) {
        prefs.remove('currentTrack');
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
    final SharedPreferences prefs = await _prefs;
    String? path = _files[index].path;
    if (path == null) return;
    prefs.setString('currentTrack', path);
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
                          ],
                        ))),
                onTap: () => navigate(index),
              );
            },
          ),
        ),
        /*Container(
          margin: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
              onPressed: openFile,
              icon: Icon(Icons.add),
              label: Text('Add track')),
        )*/
      ],
    ));
  }
}
