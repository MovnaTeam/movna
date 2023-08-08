import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/data/adapters/location_adapter.dart';
import 'package:movna/data/datasources/position_source.dart';
import 'package:movna/data/exceptions.dart';
import 'package:movna/data/repositories/repository_helper.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/location_repository.dart';
import 'package:result_type/result_type.dart';

@Injectable(as: LocationRepository)
class LocationRepositoryImpl
    with RepositoryHelper
    implements LocationRepository {
  LocationRepositoryImpl({
    required this.positionSource,
    required this.positionAdapter,
  });

  PositionSource positionSource;
  LocationAdapter positionAdapter;

  @override
  Future<Result<Location, Fault>> getLocation() async {
    try {
      Position position = await positionSource.getPosition();
      return Success(positionAdapter.modelToEntity(position));
    } catch (e, s) {
      logger.e(
        'Error getting position',
        error: e,
        stackTrace: s,
      );
      final failure = _convertDataSourceException(e);
      return Failure(failure);
    }
  }

  @override
  Stream<Result<Location, Fault>> getLocationStream() async* {
    try {
      Stream<Position> geoPositionStream = positionSource.getPositionStream();

      yield* convertStream(
        modelStream: geoPositionStream,
        adapter: positionAdapter,
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
      yield Failure(failure);
    }
  }

  Fault _convertDataSourceException(Object e) {
    return switch (e) {
      PermissionDeniedException() ||
      PermissionRequestInProgressException() =>
        const Fault.locationPermission(),
      LocationServiceDisabledException() => const Fault.locationUnavailable(),
      ConversionException() => const Fault.adapter(),
      _ => const Fault.location(),
    };
  }
}
