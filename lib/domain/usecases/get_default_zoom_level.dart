import 'package:injectable/injectable.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/user_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Retrieves the default zoom level synchronously
///
/// See [UserRepository.getDefaultZoomLevel] for more details.
@injectable
class GetDefaultZoomLevel implements UseCaseSync<double, void> {
  GetDefaultZoomLevel(this._repository);

  final UserRepository _repository;

  @override
  Result<double, Fault> call([void params]) {
    return _repository.getDefaultZoomLevel();
  }
}
