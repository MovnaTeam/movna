import 'package:injectable/injectable.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/user_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

@injectable
class SetDefaultZoomLevel implements UseCaseAsync<Unit, double> {
  SetDefaultZoomLevel(this._repository);

  final UserRepository _repository;

  @override
  Future<ResultDart<Unit, Fault>> call(double zoomLevel) {
    return _repository.setDefaultZoomLevel(zoomLevel);
  }
}
