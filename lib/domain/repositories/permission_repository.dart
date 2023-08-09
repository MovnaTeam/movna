import 'package:dartz/dartz.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/failures.dart';

abstract interface class PermissionRepository {
  Future<Either<Failure, SystemPermissionStatus>> getLocationPermission();

  /// Request the location permission and returns the [SystemPermissionStatus]
  /// this request results in.
  Future<Either<Failure, SystemPermissionStatus>> requestLocationPermission();

  Future<Either<Failure, SystemPermissionStatus>>
      getBackgroundLocationPermission();

  /// Request the notification permission and returns the
  /// [SystemPermissionStatus] this request results in.
  Future<Either<Failure, SystemPermissionStatus>>
      requestNotificationPermission();

  Future<Either<Failure, SystemPermissionStatus>> getNotificationPermission();
}
