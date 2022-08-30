import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:vieiros/utils/permission_handler.dart';

class FilesHandler {
  Future<String?> writeFile(String gpxString, String name, bool downloads) async {
    bool hasPermission = await PermissionHandler().handleWritePermission();
    if (hasPermission) {
      String directory;
      if (downloads) {
        directory = '/storage/emulated/0/Download';
      } else {
        Directory d = await getApplicationDocumentsDirectory();
        directory = '${d.path}/tracks';
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
    if(path != null){
      bool hasPermission = await PermissionHandler().handleWritePermission();
      if (hasPermission) {
        if(FileSystemEntity.isFileSync(path)){
          File deleteFile = File(path);
          deleteFile.delete();
        }else{
          Directory deleteDirectory = Directory(path);
          deleteDirectory.deleteSync(recursive: true);
        }
      }
    }
  }

  FilesHandler._privateConstructor();

  static final FilesHandler _instance = FilesHandler._privateConstructor();

  factory FilesHandler() {
    return _instance;
  }
}
