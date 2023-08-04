import 'package:dartz/dartz.dart';
import 'package:movna/domain/entities/position.dart';
import 'package:movna/domain/failures.dart';

abstract class PositionRepository {
  /// Get the current location.
  Future<Either<Failure, Position>> getPosition();

  /// Get stream of locations.
  Stream<Either<Failure, Position>> getPositionStream();
}
