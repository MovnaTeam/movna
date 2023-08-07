import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/activity_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

/// Deletes an activity from the device storage.
///
/// See [ActivityRepository.deleteActivity] for more information.
@injectable
class DeleteActivity implements UseCaseAsync<void, Activity> {
  DeleteActivity(this._repository);

  final ActivityRepository _repository;

  @override
  Future<Either<Failure, void>> call(Activity activity) {
    return _repository.deleteActivity(activity);
  }
}
