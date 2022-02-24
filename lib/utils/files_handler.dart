import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:vieiros/model/gpx_file.dart';
import 'package:vieiros/utils/permission_handler.dart';
import 'package:vieiros/utils/preferences.dart';

class FilesHandler {
  Future<String?> writeFile(String gpxString, String name, bool downloads) async {
    bool hasPermission = await PermissionHandler().handleWritePermission();
    if (hasPermission) {
      String directory;
      if (downloads) {
        directory = '/storage/emulated/0/Download';
      } else {
        Directory d = await getApplicationDocumentsDirectory();
        directory = d.path;
      }
      String path = directory + '/' + name.replaceAll(' ', '_') + '.gpx';
      if (!(await File(path).exists())) {
        await File(path).writeAsString(gpxString);
      } else {
        return '###file_exists';
      }
      String? jsonString = await Preferences().get('files');
      List<GpxFile> files = [];
      if (jsonString != null) {
        files = (json.decode(jsonString) as List)
            .map((i) => GpxFile.fromJson(i))
            .toList();
      }
      files.add(GpxFile(name: name, path: path));
      Preferences().set('files', jsonEncode(files));
      return path;
    }
    return null;
  }

  FilesHandler._privateConstructor();

  static final FilesHandler _instance = FilesHandler._privateConstructor();

  factory FilesHandler() {
    return _instance;
  }
}
