import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

/// Requests that the location service be enabled.
///
/// This usecase might result in different behaviors depending on the platform.
/// See the underlying implementation for more details.
@injectable
class RequestLocationService implements UseCaseAsync<void, void> {
  RequestLocationService(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, void>> call([void params]) {
    return _repository.requestLocationService();
  }
}
