import 'package:injectable/injectable.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/data/adapters/permission_status_adapter.dart';
import 'package:movna/data/datasources/permission_source.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/permission_repository.dart';
import 'package:result_dart/result_dart.dart';

@Injectable(as: PermissionRepository)
class PermissionRepositoryImpl implements PermissionRepository {
  PermissionRepositoryImpl(
    this._permissionSource,
    this._permissionStatusAdapter,
  );

  final PermissionSource _permissionSource;
  final PermissionStatusAdapter _permissionStatusAdapter;

  @override
  Future<ResultDart<SystemPermissionStatus, Fault>>
      getLocationPermission() async {
    try {
      final permission = await _permissionSource.getLocationPermission();
      final permissionEntity =
          _permissionStatusAdapter.modelToEntity(permission);
      return permissionEntity.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error getting location permission',
        error: e,
        stackTrace: s,
      );
      return const Fault.permission().toFailure();
    }
  }

  @override
  Future<ResultDart<SystemPermissionStatus, Fault>>
      getNotificationPermission() async {
    try {
      final permission = await _permissionSource.getNotificationPermission();
      final permissionEntity =
          _permissionStatusAdapter.modelToEntity(permission);
      return permissionEntity.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error getting notification permission',
        error: e,
        stackTrace: s,
      );
      return const Fault.permission().toFailure();
    }
  }

  @override
  Future<ResultDart<SystemPermissionStatus, Fault>>
      getBackgroundLocationPermission() async {
    try {
      final permission =
          await _permissionSource.getBackgroundLocationPermission();
      final permissionEntity =
          _permissionStatusAdapter.modelToEntity(permission);
      return permissionEntity.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error requesting background location permission',
        error: e,
        stackTrace: s,
      );
      return const Fault.permission().toFailure();
    }
  }

  @override
  Future<ResultDart<SystemPermissionStatus, Fault>>
      requestLocationPermission() async {
    try {
      final permission = await _permissionSource.requestLocationPermission();
      final permissionEntity =
          _permissionStatusAdapter.modelToEntity(permission);
      return permissionEntity.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error requesting location permission',
        error: e,
        stackTrace: s,
      );
      return const Fault.permission().toFailure();
    }
  }

  @override
  Future<ResultDart<SystemPermissionStatus, Fault>>
      requestNotificationPermission() async {
    try {
      final permission =
          await _permissionSource.requestNotificationPermission();
      final permissionEntity =
          _permissionStatusAdapter.modelToEntity(permission);
      return permissionEntity.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error requesting notification permission',
        error: e,
        stackTrace: s,
      );
      return const Fault.permission().toFailure();
    }
  }

  @override
  Future<ResultDart<bool, Fault>> shouldRequestLocation() async {
    try {
      final res = await _permissionSource.shouldRequestLocation();
      return res.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error on shouldRequestLocation',
        stackTrace: s,
        error: e,
      );
      return const Fault.permission().toFailure();
    }
  }

  @override
  Future<ResultDart<bool, Fault>> shouldRequestNotification() async {
    try {
      final res = await _permissionSource.shouldRequestNotifications();
      return res.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error on shouldRequestNotifications',
        stackTrace: s,
        error: e,
      );
      return const Fault.permission().toFailure();
    }
  }
}
