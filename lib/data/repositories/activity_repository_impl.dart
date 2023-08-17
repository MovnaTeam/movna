import 'package:injectable/injectable.dart';
import 'package:movna/data/adapters/activity_isar_adapter.dart';
import 'package:movna/data/datasources/isar_database_source.dart';
import 'package:movna/data/repositories/repository_helper.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/activity_repository.dart';
import 'package:result_dart/result_dart.dart';

@Injectable(as: ActivityRepository)
class ActivityRepositoryImpl
    with RepositoryHelper
    implements ActivityRepository {
  ActivityRepositoryImpl(this._source, this._activityAdapter);

  final IsarDataBaseSource _source;
  final ActivityIsarAdapter _activityAdapter;

  @override
  Future<Result<Unit, Fault>> saveActivity(Activity activity) async {
    try {
      final model = _activityAdapter.entityToModel(activity);
      _source.saveActivity(model);
      return unit.toSuccess();
    } catch (e) {
      return const Fault.entityNotSaved().toFailure();
    }
  }

  @override
  Future<Result<Unit, Fault>> deleteActivity(Activity activity) async {
    try {
      final model = _activityAdapter.entityToModel(activity);
      _source.deleteActivity(model.id);
      return unit.toSuccess();
    } catch (e) {
      return const Fault.entityNotDeleted().toFailure();
    }
  }

  @override
  Future<Result<List<Activity>, Fault>> getActivities() async {
    try {
      final activities = await _source.getActivities();
      return _activityAdapter.modelsToEntities(activities).toSuccess();
    } catch (e) {
      return const Fault.entityNotSourced().toFailure();
    }
  }
}
