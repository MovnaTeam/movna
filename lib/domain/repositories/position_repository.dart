import 'package:movna/domain/entities/position.dart';

abstract class PositionRepository {
  /// Get the current location.
  Future<Position> getPosition();

  /// Get stream of locations.
  Stream<Position> getPositionStream();
}
