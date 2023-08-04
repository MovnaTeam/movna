import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Datasource that interfaces with a location provider to retrieve the device's
/// location (or position)
abstract class PositionSource {
  /// Returns the current device location.
  Future<Position> getPosition();

  /// Emits the device location in a stream until cancelled.
  Stream<Position> getPositionStream();
}

@Injectable(as: PositionSource)
class PositionSourceImpl extends PositionSource {
  @override
  Future<Position> getPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  @override
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        // Set to best available accuracy.
        accuracy: LocationAccuracy.best,
      ),
    );
  }
}
