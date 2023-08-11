import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/faults.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class PermissionRepository {
  Future<Result<SystemPermissionStatus, Fault>> getLocationPermission();

  /// Request the location permission and returns the [SystemPermissionStatus]
  /// this request results in.
  Future<Result<SystemPermissionStatus, Fault>> requestLocationPermission();

  Future<Result<SystemPermissionStatus, Fault>>
      getBackgroundLocationPermission();

  /// Request the notification permission and returns the
  /// [SystemPermissionStatus] this request results in.
  Future<Result<SystemPermissionStatus, Fault>> requestNotificationPermission();

  Future<Result<SystemPermissionStatus, Fault>> getNotificationPermission();
}
