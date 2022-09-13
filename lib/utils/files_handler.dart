import 'dart:io';
import 'dart:isolate';
import 'package:path_provider/path_provider.dart';
import 'package:vieiros/utils/permission_handler.dart';

class FilesHandler {
  Future<String?> writeFile(String gpxString, String name, newPath, bool downloads) async {
    bool hasPermission = await PermissionHandler().handleWritePermission();
    if (hasPermission) {
      String directory;
      if (downloads) {
        directory = '${(await getApplicationDocumentsDirectory()).path}/tracks';
      } else {
        directory = newPath;
      }
      String path = '$directory/${name.replaceAll(' ', '_')}.gpx';
      if (!File(path).existsSync()) {
        File(path).writeAsStringSync(gpxString);
      } else {
        return '###file_exists';
      }
      return path;
    }
    return null;
  }

  void removeFile(String? path) async {
    if (path != null) {
      bool hasPermission = await PermissionHandler().handleWritePermission();
      if (hasPermission) {
        if (FileSystemEntity.isFileSync(path)) {
          File deleteFile = File(path);
          deleteFile.delete();
        } else {
          Directory deleteDirectory = Directory(path);
          deleteDirectory.deleteSync(recursive: true);
        }
      }
    }
  }

  Future<List<FileSystemEntity>> listFiles (Directory directory) async {
      List<FileSystemEntity> files = [];
      ReceivePort receivePort = ReceivePort();
      Isolate isolate = await Isolate.spawn(computeListFiles, [directory, receivePort.sendPort]);
      files = await receivePort.first;
      isolate.kill(priority: Isolate.immediate);
      return files;
  }

  void computeListFiles(List<dynamic> params){
    SendPort sendPort = params[1];
     List<FileSystemEntity> files = params[0].listSync();
     sendPort.send(files);
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

  Future<bool> isFile(String path) async {
    bool isFile = false;
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(computeIsFile, [path, receivePort.sendPort]);
    isFile = await receivePort.first;
    isolate.kill(priority: Isolate.immediate);
    return isFile;
  }

  void computeIsFile(List<dynamic> params){
    SendPort sendPort = params[1];
    bool isFile = FileSystemEntity.isFileSync(params[0]);
    sendPort.send(isFile);
  }

  FilesHandler._privateConstructor();

  static final FilesHandler _instance = FilesHandler._privateConstructor();

  factory FilesHandler() {
    return _instance;
  }
}
