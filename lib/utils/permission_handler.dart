import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {

  Future<bool> handleWritePermission() async{
    bool hasPermission = await Permission.storage.isGranted;
    if (hasPermission) return true;
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> handleLocationPermission() async{
    bool _hasPermission = await Permission.locationAlways.isGranted;
    if (_hasPermission) return true;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Platform.isAndroid && androidInfo.version.sdkInt! >= 30) {
      final status = await Permission.location.request();
      if (status == PermissionStatus.permanentlyDenied) {
        return await Geolocator.openLocationSettings();
      }
    }
    final status = await Permission.locationAlways.request();
    return status == PermissionStatus.granted;
  }

  PermissionHandler._privateConstructor();

  static final PermissionHandler _instance = PermissionHandler._privateConstructor();

  factory PermissionHandler(){
    return _instance;
  }
}