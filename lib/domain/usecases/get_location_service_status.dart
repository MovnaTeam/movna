import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

@injectable
class GetLocationServiceStatus
    implements UseCaseAsync<LocationServiceStatus, void> {
  GetLocationServiceStatus(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, LocationServiceStatus>> call([void params]) {
    return _repository.getLocationServiceStatus();
  }
}
