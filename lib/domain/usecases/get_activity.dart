import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/activity_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Returns a specific activity stored on the device.
///
/// See [ActivityRepository.getActivities] for more information.
@injectable
class GetActivity implements UseCaseAsync<Activity, String> {
  GetActivity(this._repository);

  final ActivityRepository _repository;

  @override
  Future<ResultDart<Activity, Fault>> call(String activityUuid) {
    return _repository.getActivity(activityUuid);
  }
}
