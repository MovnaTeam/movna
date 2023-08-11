import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/activity_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Returns all activities stored on the device.
///
/// See [ActivityRepository.getActivities] for more information.
@injectable
class GetActivities implements UseCaseAsync<List<Activity>, void> {
  GetActivities(this._repository);

  final ActivityRepository _repository;

  @override
  Future<Result<List<Activity>, Fault>> call([void p]) {
    return _repository.getActivities();
  }
}
