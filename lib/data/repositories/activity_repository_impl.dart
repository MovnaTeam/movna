import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/data/adapters/activity_isar_adapter.dart';
import 'package:movna/data/datasources/isar_database_source.dart';
import 'package:movna/data/repositories/repository_helper.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/activity_repository.dart';

@Injectable(as: ActivityRepository)
class ActivityRepositoryImpl
    with RepositoryHelper
    implements ActivityRepository {
  ActivityRepositoryImpl(this._source, this._activityAdapter);

  final IsarDataBaseSource _source;
  final ActivityIsarAdapter _activityAdapter;

  @override
  Future<Either<Failure, void>> saveActivity(Activity activity) async {
    try {
      final model = _activityAdapter.entityToModel(activity);
      _source.saveActivity(model);
      return const Right(null);
    } catch (e) {
      return const Left(Failure.databaseNotSaved());
    }
  }

  @override
  Future<Either<Failure, void>> deleteActivity(Activity activity) async {
    try {
      final model = _activityAdapter.entityToModel(activity);
      _source.deleteActivity(model.id);
      return const Right(null);
    } catch (e) {
      return const Left(Failure.databaseNotSaved());
    }
  }

  @override
  Future<Either<Failure, List<Activity>>> getActivities() async {
    try {
      final either = await _source.getActivities();
      return either.fold((failure) {
        return Left(failure);
      }, (activities) {
        return Right(_activityAdapter.modelsToEntities(activities));
      });
    } catch (e) {
      return const Left(Failure.database());
    }
  }
}
