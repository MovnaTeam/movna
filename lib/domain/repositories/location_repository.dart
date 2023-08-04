import 'package:dartz/dartz.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/failures.dart';

abstract class LocationRepository {
  /// Get the current device location.
  Future<Either<Failure, Location>> getLocation();

  /// Get stream of device locations.
  Stream<Either<Failure, Location>> getLocationStream();
}
