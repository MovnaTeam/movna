import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/activity_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

/// Saves an activity on the device storage.
///
/// See [ActivityRepository.saveActivity] for more information.
@injectable
class SaveActivity implements UseCaseAsync<void, Activity> {
  SaveActivity({required this.repository});

  final ActivityRepository repository;

  @override
  Future<Either<Failure, void>> call(Activity activity) {
    return repository.saveActivity(activity);
  }
}
