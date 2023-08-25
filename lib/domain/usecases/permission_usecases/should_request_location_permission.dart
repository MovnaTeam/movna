import 'package:injectable/injectable.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/permission_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// A usecase querying whether or not the application should show a dialog
/// prompting the user for granting location access permission.
@injectable
class ShouldRequestLocationPermission implements UseCaseAsync<bool, void> {
  ShouldRequestLocationPermission(this._repository);

  final PermissionRepository _repository;

  @override
  Future<Result<bool, Fault>> call([void params]) {
    return _repository.shouldRequestLocation();
  }
}
