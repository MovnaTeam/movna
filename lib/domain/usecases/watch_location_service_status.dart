import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/timed_location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Emits a new [LocationServiceStatus] every time the location service is
/// switched on or off.
@injectable
class WatchLocationServiceStatus
    implements UseCaseStream<LocationServiceStatus, void> {
  WatchLocationServiceStatus(this._repository);

  final TimedLocationRepository _repository;

  @override
  Stream<Result<LocationServiceStatus, Fault>> call([void params]) {
    return _repository.watchLocationServiceStatus();
  }
}
