import 'dart:io';
import 'dart:isolate';
import 'package:path_provider/path_provider.dart';
import 'package:vieiros/utils/permission_handler.dart';
import 'package:vieiros/utils/preferences.dart';

class FilesHandler {
  Future<String?> writeFile(String gpxString, String name, newPath, bool downloads) async {
    bool hasPermission = await PermissionHandler().handleWritePermission();
    if (hasPermission) {
      String path;
      if (downloads) {
        path = '${(await getApplicationDocumentsDirectory()).path}/tracks/${name.replaceAll(' ', '_')}.gpx';
      } else {
        path = newPath;
      }
      if (!File(path).existsSync()) {
        File(path).writeAsStringSync(gpxString);
        Preferences().set(path, name);
      } else {
        return '###file_exists';
      }
      return path;
    }
    return null;
  }

  Future<void> removeFile(String? path) async {
    if (path != null) {
      bool hasPermission = await PermissionHandler().handleWritePermission();
      if (hasPermission) {
        if (FileSystemEntity.isFileSync(path)) {
          Preferences().remove(path);
          File deleteFile = File(path);
          deleteFile.delete();
        } else {
          Directory deleteDirectory = Directory(path);
          deleteDirectory.deleteSync(recursive: true);
        }
      }
    }
  }

  Future<String> readAsStringAsync(File file) async {
    if(file.path != '/loading'){
      String stringFile = '';
      ReceivePort receivePort = ReceivePort();
      Isolate isolate = await Isolate.spawn(computeReadAsStringAsync, [file, receivePort.sendPort]);
      stringFile = await receivePort.first;
      isolate.kill(priority: Isolate.immediate);
      return stringFile;
    }else{
      return '';
    }
  }

  void computeReadAsStringAsync(List<dynamic> params){
    SendPort sendPort = params[1];
    String stringFile = params[0].readAsStringSync();
    sendPort.send(stringFile);
  }

  FilesHandler._privateConstructor();

  static final FilesHandler _instance = FilesHandler._privateConstructor();

  factory FilesHandler() {
    return _instance;
  }
}
