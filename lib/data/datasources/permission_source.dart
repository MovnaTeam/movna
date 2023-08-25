import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

abstract interface class PermissionSource {
  Future<PermissionStatus> requestNotificationPermission();

  Future<PermissionStatus> getNotificationPermission();

  Future<PermissionStatus> getLocationPermission();

  Future<PermissionStatus> requestLocationPermission();

  Future<PermissionStatus> getBackgroundLocationPermission();

  /// Returns whether or not the application should request the location
  /// permission via a dialog or simply redirect the user to the app's settings.
  Future<bool> shouldRequestLocation();

  /// Returns whether or not the application should request the notifications
  /// permission via a dialog or simply redirect the user to the app's settings.
  Future<bool> shouldRequestNotifications();
}

@Injectable(as: PermissionSource)
class PermissionSourceImpl implements PermissionSource {
  @override
  Future<PermissionStatus> requestLocationPermission() {
    return Permission.location.request();
  }

  @override
  Future<PermissionStatus> getLocationPermission() {
    return Permission.locationWhenInUse.status;
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

  @override
  Future<bool> shouldRequestLocation() {
    return Permission.location.shouldShowRequestRationale;
  }

  @override
  Future<bool> shouldRequestNotifications() {
    return Permission.notification.shouldShowRequestRationale;
  }
}
