import 'package:movna/core/domain/entities/position.dart';

abstract class PositionRepository {
  /// Get the current location.
  Future<Position> getPosition();

  /// Get stream of locations.
  Future<Stream<Position>> getPositionStream();
}
