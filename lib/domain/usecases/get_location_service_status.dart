import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

@injectable
class GetLocationServiceStatus
    implements UseCaseAsync<LocationServiceStatus, void> {
  GetLocationServiceStatus(this._repository);

  final LocationRepository _repository;

  @override
  Future<Result<LocationServiceStatus, Fault>> call([void params]) {
    return _repository.getLocationServiceStatus();
  }
}
