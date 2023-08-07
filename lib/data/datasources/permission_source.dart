import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

abstract interface class PermissionSource {
  Future<PermissionStatus> requestNotificationPermission();

  Future<PermissionStatus> getNotificationPermission();

  Future<PermissionStatus> getLocationPermission();

  Future<PermissionStatus> requestLocationPermission();

  Future<PermissionStatus> getBackgroundLocationPermission();
}

@Injectable(as: PermissionSource)
class PermissionSourceImpl implements PermissionSource {
  @override
  Future<PermissionStatus> requestLocationPermission() {
    return Permission.location.request();
  }

  @override
  Future<PermissionStatus> getLocationPermission() {
    return Permission.location.status;
  }

  @override
  Future<PermissionStatus> getNotificationPermission() {
    return Permission.notification.status;
  }

  @override
  Future<PermissionStatus> requestNotificationPermission() {
    return Permission.notification.request();
  }

  @override
  Future<PermissionStatus> getBackgroundLocationPermission() {
    return Permission.locationAlways.status;
  }
}
