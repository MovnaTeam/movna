import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:injectable/injectable.dart';
import 'package:movna/data/adapters/position_adapter.dart';
import 'package:movna/data/datasources/position_source.dart';
import 'package:movna/domain/entities/position.dart' as domain;
import 'package:movna/domain/repositories/position_repository.dart';

@Injectable(as: PositionRepository)
class PositionRepositoryImpl implements PositionRepository {
  PositionRepositoryImpl({
    required this.positionSource,
    required this.positionAdapter,
  });

  PositionSource positionSource;
  PositionAdapter positionAdapter;

  @override
  Future<domain.Position> getPosition() async {
    geolocator.Position position = await positionSource.getPosition();
    return positionAdapter.modelToEntity(position);
  }

  @override
  Stream<domain.Position> getPositionStream() {
    Stream<geolocator.Position> geoPositionStream =
        positionSource.getPositionStream();
    return geoPositionStream.map(
      (position) => positionAdapter.modelToEntity(position),
    );
  }
}
