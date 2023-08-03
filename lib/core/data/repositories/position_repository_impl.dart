import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:injectable/injectable.dart';
import 'package:movna/core/data/datasources/position_source.dart';
import 'package:movna/core/domain/entities/position.dart' as domain;
import 'package:movna/core/domain/repositories/position_repository.dart';

@Injectable(as: PositionRepository)
class PositionRepositoryImpl implements PositionRepository {
  PositionRepositoryImpl({required this.positionSource});
  PositionSource positionSource;

  static domain.Position _positionGeolocatorToDomain(geolocator.Position pos) =>
      domain.Position(
        latitudeInDegrees: pos.latitude,
        longitudeInDegrees: pos.longitude,
        accuracyInMeters: pos.accuracy,
        altitudeInMeters: pos.altitude,
        headingInDegrees: pos.heading,
        speedAccuracyInMetersPerSecond: pos.speedAccuracy,
        speedInMetersPerSecond: pos.speed,
        timestamp: pos.timestamp,
      );

  @override
  Future<domain.Position> getPosition() async {
    geolocator.Position position = await positionSource.getPosition();
    return _positionGeolocatorToDomain(position);
  }

  @override
  Future<Stream<domain.Position>> getPositionStream() async {
    Stream<geolocator.Position> geoPositionStream =
        await positionSource.getPositionStream();
    return geoPositionStream.map(
      (position) => _positionGeolocatorToDomain(position),
    );
  }
}
