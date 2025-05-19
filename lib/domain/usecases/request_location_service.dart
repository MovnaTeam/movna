import 'package:injectable/injectable.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/timed_location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Requests that the location service be enabled.
///
/// This usecase might result in different behaviors depending on the platform.
/// See the underlying implementation for more details.
@injectable
class RequestLocationService implements UseCaseAsync<Unit, void> {
  RequestLocationService(this._repository);

  final TimedLocationRepository _repository;

  @override
  Future<ResultDart<Unit, Fault>> call([void params]) {
    return _repository.requestLocationService();
  }
}
