import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:injectable/injectable.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/data/adapters/position_adapter.dart';
import 'package:movna/data/datasources/position_source.dart';
import 'package:movna/domain/entities/position.dart' as d;
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/position_repository.dart';
import 'package:movna/data/repositories/repository_helper.dart';

@Injectable(as: PositionRepository)
class PositionRepositoryImpl
    with RepositoryHelper
    implements PositionRepository {
  PositionRepositoryImpl({
    required this.positionSource,
    required this.positionAdapter,
  });

  PositionSource positionSource;
  PositionAdapter positionAdapter;

  @override
  Future<Either<Failure, d.Position>> getPosition() async {
    try {
      g.Position position = await positionSource.getPosition();
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
  Stream<Either<Failure, d.Position>> getPositionStream() async* {
    try {
      Stream<g.Position> geoPositionStream = positionSource.getPositionStream();

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
      g.PermissionDeniedException() ||
      g.PermissionRequestInProgressException() =>
        const Failure.locationPermission(),
      g.LocationServiceDisabledException() =>
        const Failure.locationUnavailable(),
      _ => const Failure.location(),
    };
  }
}
