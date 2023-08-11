import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/timed_location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Returns the device current [TimedLocation] or a [Fault] if the location could
/// not be retrieved.
///
/// See [LocationRepository.getLocation] for more details.
@injectable
class GetLocation implements UseCaseAsync<TimedLocation, void> {
  GetLocation({required this.repository});

  final TimedLocationRepository repository;

  @override
  Future<Result<TimedLocation, Fault>> call([void p]) {
    return repository.getTimedLocation();
  }
}
