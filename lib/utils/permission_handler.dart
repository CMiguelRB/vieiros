import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {

  Future<bool> handleWritePermission() async{
    if(Platform.isAndroid){
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if(androidInfo.version.sdkInt! < 33){
        bool hasPermission = await Permission.storage.isGranted;
        if (hasPermission) return true;
        final status = await Permission.storage.request();
        return status == PermissionStatus.granted;
      }
    }
    return true;
  }

  Future<bool> handleLocationPermission() async{
    bool hasPermission = await Permission.locationWhenInUse.isGranted;
    if (hasPermission) return true;
    final status = await Permission.locationWhenInUse.request();
    return status == PermissionStatus.granted;
  }

  PermissionHandler._privateConstructor();

  static final PermissionHandler _instance = PermissionHandler._privateConstructor();

  factory PermissionHandler(){
    return _instance;
  }
}