import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

abstract class PositionSource {
  Future<Position> getPosition();
  Future<Stream<Position>> getPositionStream();
}

@Injectable(as: PositionSource)
class PositionSourceImpl extends PositionSource {
  @override
  Future<Position> getPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  @override
  Future<Stream<Position>> getPositionStream() async {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        // Set to best available accuracy.
        accuracy: LocationAccuracy.best,
      ),
    );
  }
}
