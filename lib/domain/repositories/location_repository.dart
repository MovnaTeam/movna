import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/faults.dart';
import 'package:result_dart/result_dart.dart';

abstract class LocationRepository {
  /// Get the current device location.
  Future<Result<Location, Fault>> getLocation();

  /// Get stream of device locations.
  Stream<Result<Location, Fault>> getLocationStream();
}
