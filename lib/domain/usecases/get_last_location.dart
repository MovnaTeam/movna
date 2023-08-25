import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// A usecase that returns the last known coordinates of the device
@injectable
class GetLastCoords implements UseCaseAsync<GpsCoordinates, void> {
  @override
  Future<Result<GpsCoordinates, Fault>> call([void params]) async {
    // TODO https://github.com/MovnaTeam/movna/issues/20
    return const Fault.unknown().toFailure();
  }
}
