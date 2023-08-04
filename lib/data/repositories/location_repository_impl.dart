import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/data/adapters/location_adapter.dart';
import 'package:movna/data/datasources/position_source.dart';
import 'package:movna/data/exceptions.dart';
import 'package:movna/data/repositories/repository_helper.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/location_repository.dart';

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
  Future<Either<Failure, Location>> getLocation() async {
    try {
      Position position = await positionSource.getPosition();
      return Right(positionAdapter.modelToEntity(position));
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
  Stream<Either<Failure, Location>> getLocationStream() async* {
    try {
      Stream<Position> geoPositionStream = positionSource.getPositionStream();

      yield* convertStream(
        modelStream: geoPositionStream,
        adapter: positionAdapter,
        errorHandler: _convertDataSourceException,
        errorLoggerMessage: 'Error getting position stream',
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
}
