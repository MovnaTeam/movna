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
  GetActivities({required this.repository});

  final ActivityRepository repository;

  @override
  Future<Either<Failure, List<Activity>>> call([void p]) {
    return repository.getActivities();
  }
}
