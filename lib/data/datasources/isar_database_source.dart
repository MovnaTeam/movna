import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/data/models/activity_model.dart';
import 'package:movna/domain/failures.dart';

@Injectable()
class IsarDataBaseSource {
  /// Returns global isar instance registered at app startup.
  Future<Either<Failure, Isar>> _getIsar() async {
    return injector.getAsync<Either<Failure, Isar>>();
  }

  /// Returns activity models sorted by start time.
  Future<Either<Failure, List<ActivityModel>>> getActivities() async {
    final either = await _getIsar();
    return either.fold((failure) {
      return const Left(Failure.databaseNotOpened());
    }, (isar) async {
      return Right(
        await isar.activityModels.where().sortByStartTimeDesc().findAll(),
      );
    });
  }

  /// Save activity to database.
  Future<Either<Failure, void>> saveActivity(ActivityModel model) async {
    final either = await _getIsar();
    return either.fold((failure) {
      return Left(failure);
    }, (isar) async {
      final id = await isar.writeTxn(() async {
        return await isar.activityModels.put(model);
      });
      if (id != model.id) {
        return const Left(Failure.databaseNotSaved());
      } else {
        return const Right(null);
      }
    });
  }

  /// Delete activity with ID [id] from database.
  Future<Either<Failure, void>> deleteActivity(Id id) async {
    final either = await _getIsar();

    return either.fold((failure) {
      return Left(failure);
    }, (isar) async {
      final deleted = await isar.writeTxn(() async {
        return await isar.activityModels.delete(id);
      });
      if (!deleted) {
        return const Left(Failure.databaseNotDeleted());
      } else {
        return const Right(null);
      }
    });
  }
}
