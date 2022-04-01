import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {

  Future<bool> handleWritePermission() async{
    bool hasPermission = await Permission.storage.isGranted;
    if (hasPermission) return true;
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> handleLocationPermission() async{
    bool _hasPermission = await Permission.locationWhenInUse.isGranted;
    if (_hasPermission) return true;
    final status = await Permission.locationWhenInUse.request();
    return status == PermissionStatus.granted;
  }

  PermissionHandler._privateConstructor();

  static final PermissionHandler _instance = PermissionHandler._privateConstructor();

  factory PermissionHandler(){
    return _instance;
  }
}