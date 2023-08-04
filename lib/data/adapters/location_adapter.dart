import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/data/adapters/base_adapter.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';
import 'package:movna/domain/entities/location.dart';

@injectable
class LocationAdapter extends BaseAdapter<Location, Position> {
  @override
  Location modelToEntity(Position m) {
    return Location(
      gpsCoordinates: GpsCoordinates(m.latitude, m.longitude),
      errorInMeters: m.accuracy,
      altitudeInMeters: m.altitude,
      headingInDegrees: m.heading,
      speedErrorInMetersPerSecond: m.speedAccuracy,
      speedInMetersPerSecond: m.speed,
      timestamp: m.timestamp,
    );
  }
}
