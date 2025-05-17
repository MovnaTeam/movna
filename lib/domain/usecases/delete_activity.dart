import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/activity_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Deletes an activity from the device storage.
///
/// See [ActivityRepository.deleteActivity] for more information.
@injectable
class DeleteActivity implements UseCaseAsync<Unit, Activity> {
  DeleteActivity(this._repository);

  final ActivityRepository _repository;

  @override
  Future<ResultDart<Unit, Fault>> call(Activity activity) {
    return _repository.deleteActivity(activity);
  }
}
