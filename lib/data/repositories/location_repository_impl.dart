import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/data/adapters/location_adapter.dart';
import 'package:movna/data/adapters/notification_config_adapter.dart';
import 'package:movna/data/datasources/position_source.dart';
import 'package:movna/data/exceptions.dart';
import 'package:movna/data/repositories/repository_helper.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/location_repository.dart';

@Injectable(as: LocationRepository)
class LocationRepositoryImpl
    with RepositoryHelper
    implements LocationRepository {
  LocationRepositoryImpl(
    this._positionSource,
    this._positionAdapter,
    this._notificationConfigAdapter,
  );

  final PositionSource _positionSource;
  final LocationAdapter _positionAdapter;
  final NotificationConfigAdapter _notificationConfigAdapter;

  @override
  Future<Either<Failure, Location>> getLocation() async {
    try {
      Position position = await _positionSource.getPosition();
      return Right(_positionAdapter.modelToEntity(position));
    } catch (e, s) {
      logger.e(
        'Error getting position',
        error: e,
        stackTrace: s,
      );
      final failure = _convertDataSourceException(e);
      return Left(failure);
    }
  }

  @override
  Stream<Either<Failure, Location>> getLocationStream(
    NotificationConfig notificationConfig,
  ) async* {
    try {
      Stream<Position> geoPositionStream = _positionSource.getPositionStream(
        _notificationConfigAdapter.entityToModel(notificationConfig),
      );

      yield* convertStream(
        modelStream: geoPositionStream,
        adapter: _positionAdapter,
        errorHandler: _convertDataSourceException,
        errorLoggerMessage: 'Error in position stream',
      );
    } catch (e, s) {
      logger.e(
        'Error getting position stream',
        error: e,
        stackTrace: s,
      );
      final failure = _convertDataSourceException(e);
      yield Left(failure);
    }
  }

  Failure _convertDataSourceException(Object e) {
    return switch (e) {
      PermissionDeniedException() ||
      PermissionRequestInProgressException() =>
        const Failure.locationPermission(),
      LocationServiceDisabledException() => const Failure.locationUnavailable(),
      ConversionException() => const Failure.adapter(),
      _ => const Failure.location(),
    };
  }

  @override
  Future<Either<Failure, LocationServiceStatus>>
      getLocationServiceStatus() async {
    try {
      final res = await _positionSource.isLocationServiceEnabled();

      return Right(
        res ? LocationServiceStatus.enabled : LocationServiceStatus.disabled,
      );
    } catch (e, s) {
      logger.e(
        'Error getting location service status',
        error: e,
        stackTrace: s,
      );
      return const Left(Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, void>> requestLocationService() async {
    try {
      await _positionSource.requestLocationService();
      return const Right(null);
    } catch (e, s) {
      logger.e(
        'Error requesting location service',
        error: e,
        stackTrace: s,
      );
      return const Left(Failure.unknown());
    }
  }
}
