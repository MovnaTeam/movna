import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/permission_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Request the location permission and returns the [SystemPermissionStatus]
/// this request results in.
@injectable
class RequestLocationPermission
    implements UseCaseAsync<SystemPermissionStatus, SystemPermissionStatus> {
  RequestLocationPermission(this._repository);

  final PermissionRepository _repository;

  @override
  Future<Result<SystemPermissionStatus, Fault>> call([void params]) {
    return _repository.requestLocationPermission();
  }
}
