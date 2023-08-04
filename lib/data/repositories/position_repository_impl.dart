import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:injectable/injectable.dart';
import 'package:movna/data/datasources/position_source.dart';
import 'package:movna/domain/entities/position.dart' as domain;
import 'package:movna/domain/repositories/position_repository.dart';

@Injectable(as: PositionRepository)
class PositionRepositoryImpl implements PositionRepository {
  PositionRepositoryImpl({required this.positionSource});

  PositionSource positionSource;

  static domain.Position _positionGeolocatorToDomain(geolocator.Position pos) =>
      domain.Position(
        latitudeInDegrees: pos.latitude,
        longitudeInDegrees: pos.longitude,
        errorInMeters: pos.accuracy,
        altitudeInMeters: pos.altitude,
        headingInDegrees: pos.heading,
        speedErrorInMetersPerSecond: pos.speedAccuracy,
        speedInMetersPerSecond: pos.speed,
        timestamp: pos.timestamp,
      );

  @override
  Future<domain.Position> getPosition() async {
    geolocator.Position position = await positionSource.getPosition();
    return _positionGeolocatorToDomain(position);
  }

  @override
  Stream<domain.Position> getPositionStream() {
    Stream<geolocator.Position> geoPositionStream =
        positionSource.getPositionStream();
    return geoPositionStream.map(
      (position) => _positionGeolocatorToDomain(position),
    );
  }
}
