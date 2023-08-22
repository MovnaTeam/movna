import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/activity_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Saves an activity on the device storage.
///
/// See [ActivityRepository.saveActivity] for more information.
@injectable
class SaveActivity implements UseCaseAsync<Unit, Activity> {
  SaveActivity(this._repository);

  final ActivityRepository _repository;

  @override
  Future<Result<Unit, Fault>> call(Activity activity) {
    return _repository.saveActivity(activity);
  }
}
