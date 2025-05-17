import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/data/adapters/location_service_status_adapter.dart';
import 'package:movna/data/adapters/notification_config_adapter.dart';
import 'package:movna/data/adapters/timed_location_adapter.dart';
import 'package:movna/data/datasources/position_source.dart';
import 'package:movna/data/exceptions.dart';
import 'package:movna/data/repositories/repository_helper.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/timed_location_repository.dart';
import 'package:result_dart/result_dart.dart';

@Injectable(as: TimedLocationRepository)
class TimedLocationRepositoryImpl
    with RepositoryHelper
    implements TimedLocationRepository {
  TimedLocationRepositoryImpl(
    this._positionSource,
    this._timedLocationAdapter,
    this._notificationConfigAdapter,
    this._locationServiceStatusAdapter,
  );

  final PositionSource _positionSource;
  final TimedLocationAdapter _timedLocationAdapter;
  final NotificationConfigAdapter _notificationConfigAdapter;
  final LocationServiceStatusAdapter _locationServiceStatusAdapter;

  @override
  Future<ResultDart<TimedLocation, Fault>> getLastKnownLocation() async {
    try {
      final position = await _positionSource.getLastKnownPosition();
      final location = _timedLocationAdapter.modelToEntityOrNull(position);
      return location == null
          ? const Fault.location().toFailure()
          : location.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error getting last known position',
        error: e,
        stackTrace: s,
      );
      final fault = _convertDataSourceException(e);
      return fault.toFailure();
    }
  }

  @override
  Future<ResultDart<TimedLocation, Fault>> getTimedLocation() async {
    try {
      Position position = await _positionSource.getPosition();
      return _timedLocationAdapter.modelToEntity(position).toSuccess();
    } catch (e, s) {
      logger.e(
        'Error getting position',
        error: e,
        stackTrace: s,
      );
      final fault = _convertDataSourceException(e);
      return fault.toFailure();
    }
  }

  @override
  Stream<ResultDart<TimedLocation, Fault>> getTimedLocationStream(
    NotificationConfig notificationConfig,
  ) async* {
    try {
      Stream<Position> geoPositionStream = _positionSource.getPositionStream(
        _notificationConfigAdapter.entityToModel(notificationConfig),
      );

      yield* convertStream(
        modelStream: geoPositionStream,
        adapter: _timedLocationAdapter,
        errorHandler: _convertDataSourceException,
        errorLoggerMessage: 'Error in position stream',
      );
    } catch (e, s) {
      logger.e(
        'Error getting position stream',
        error: e,
        stackTrace: s,
      );
      final fault = _convertDataSourceException(e);
      yield fault.toFailure();
    }
  }

  Fault _convertDataSourceException(Object e) {
    return switch (e) {
      PermissionDeniedException() ||
      PermissionRequestInProgressException() =>
        const Fault.locationPermission(),
      LocationServiceDisabledException() => const Fault.locationUnavailable(),
      ConversionException() => const Fault.entityNotSourced(),
      _ => const Fault.location(),
    };
  }

  @override
  Future<ResultDart<LocationServiceStatus, Fault>>
      getLocationServiceStatus() async {
    try {
      final res = await _positionSource.isLocationServiceEnabled()
          ? LocationServiceStatus.enabled
          : LocationServiceStatus.disabled;
      return res.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error getting location service status',
        error: e,
        stackTrace: s,
      );
      return const Fault.location().toFailure();
    }
  }

  @override
  Future<ResultDart<Unit, Fault>> requestLocationService() async {
    try {
      await _positionSource.requestLocationService();
      return unit.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error requesting location service',
        error: e,
        stackTrace: s,
      );
      return const Fault.location().toFailure();
    }
  }

  @override
  Stream<ResultDart<LocationServiceStatus, Fault>>
      watchLocationServiceStatus() async* {
    try {
      final statusStream = _positionSource.watchLocationServiceStatus();
      yield* convertStream(
        errorLoggerMessage: 'Error in location service status stream',
        errorHandler: (_) => const Fault.location(),
        adapter: _locationServiceStatusAdapter,
        modelStream: statusStream,
      );
    } catch (e, s) {
      logger.e(
        'Error getting location service status stream',
        error: e,
        stackTrace: s,
      );
      yield const Fault.location().toFailure();
    }
  }
}
