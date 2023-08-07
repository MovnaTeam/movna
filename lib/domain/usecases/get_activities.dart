import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/activity_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

/// Returns all activities stored on the device.
///
/// See [ActivityRepository.getActivities] for more information.
@injectable
class GetActivities implements UseCaseAsync<List<Activity>, void> {
  GetActivities(this._repository);

  final ActivityRepository _repository;

  @override
  Future<Either<Failure, List<Activity>>> call([void p]) {
    return _repository.getActivities();
  }
}
