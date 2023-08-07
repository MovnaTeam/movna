import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/data/adapters/permission_status_adapter.dart';
import 'package:movna/data/datasources/permission_source.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/permission_repository.dart';

@Injectable(as: PermissionRepository)
class PermissionRepositoryImpl implements PermissionRepository {
  PermissionRepositoryImpl(
    this._permissionSource,
    this._permissionStatusAdapter,
  );

  final PermissionSource _permissionSource;
  final PermissionStatusAdapter _permissionStatusAdapter;

  @override
  Future<Either<Failure, SystemPermissionStatus>>
      getLocationPermission() async {
    try {
      final permission = await _permissionSource.getLocationPermission();
      final permissionEntity =
          _permissionStatusAdapter.modelToEntity(permission);
      return Right(permissionEntity);
    } catch (e, s) {
      logger.e(
        'Error getting location permission',
        error: e,
        stackTrace: s,
      );
      return const Left(Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, SystemPermissionStatus>>
      getNotificationPermission() async {
    try {
      final permission = await _permissionSource.getNotificationPermission();
      final permissionEntity =
          _permissionStatusAdapter.modelToEntity(permission);
      return Right(permissionEntity);
    } catch (e, s) {
      logger.e(
        'Error getting notification permission',
        error: e,
        stackTrace: s,
      );
      return const Left(Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, SystemPermissionStatus>>
      getBackgroundLocationPermission() async {
    try {
      final permission =
          await _permissionSource.getBackgroundLocationPermission();
      final permissionEntity =
          _permissionStatusAdapter.modelToEntity(permission);
      return Right(permissionEntity);
    } catch (e, s) {
      logger.e(
        'Error requesting background location permission',
        error: e,
        stackTrace: s,
      );
      return const Left(Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, SystemPermissionStatus>>
      requestLocationPermission() async {
    try {
      final permission = await _permissionSource.requestLocationPermission();
      final permissionEntity =
          _permissionStatusAdapter.modelToEntity(permission);
      return Right(permissionEntity);
    } catch (e, s) {
      logger.e(
        'Error requesting location permission',
        error: e,
        stackTrace: s,
      );
      return const Left(Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, SystemPermissionStatus>>
      requestNotificationPermission() async {
    try {
      final permission =
          await _permissionSource.requestNotificationPermission();
      final permissionEntity =
          _permissionStatusAdapter.modelToEntity(permission);
      return Right(permissionEntity);
    } catch (e, s) {
      logger.e(
        'Error requesting notification permission',
        error: e,
        stackTrace: s,
      );
      return const Left(Failure.unknown());
    }
  }
}
