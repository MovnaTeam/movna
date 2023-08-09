import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/permission_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

/// Request the location permission and returns the [SystemPermissionStatus]
/// this request results in.
@injectable
class RequestLocationPermission
    implements UseCaseAsync<SystemPermissionStatus, SystemPermissionStatus> {
  RequestLocationPermission(this._repository);

  final PermissionRepository _repository;

  @override
  Future<Either<Failure, SystemPermissionStatus>> call([void params]) {
    return _repository.requestLocationPermission();
  }
}
