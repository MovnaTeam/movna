import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/permission_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

/// Request the notification permission and returns the [SystemPermissionStatus]
/// this request results in.
@injectable
class RequestNotificationPermission
    implements UseCaseAsync<SystemPermissionStatus, void> {
  RequestNotificationPermission(this._repository);

  final PermissionRepository _repository;

  @override
  Future<Either<Failure, SystemPermissionStatus>> call([void params]) {
    return _repository.requestNotificationPermission();
  }
}
