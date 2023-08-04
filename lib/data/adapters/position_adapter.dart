import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:injectable/injectable.dart';
import 'package:movna/data/adapters/base_adapter.dart';
import 'package:movna/domain/entities/position.dart' as domain;


@injectable
class PositionAdapter
    extends BaseAdapter<domain.Position, geolocator.Position> {
  @override
  domain.Position modelToEntity(geolocator.Position m) => domain.Position(
    latitudeInDegrees: m.latitude,
    longitudeInDegrees: m.longitude,
    errorInMeters: m.accuracy,
    altitudeInMeters: m.altitude,
    headingInDegrees: m.heading,
    speedErrorInMetersPerSecond: m.speedAccuracy,
    speedInMetersPerSecond: m.speed,
    timestamp: m.timestamp,
  );
}
