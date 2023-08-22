import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:movna/core/modules/isar_module.dart';
import 'package:movna/data/exceptions.dart';
import 'package:movna/data/models/activity_model.dart';

@injectable
class IsarDataBaseSource {
  IsarDataBaseSource(@baseIsar this._isar);

  final Isar _isar;

  /// Returns activity models sorted by start time.
  Future<List<ActivityModel>> getActivities() async {
    return await _isar.activityModels.where().sortByStartTimeDesc().findAll();
  }

  /// Save activity to database.
  /// Throws a [DatabaseAccessException] if something goes wrong.
  void saveActivity(ActivityModel model) async {
    final id = await _isar.writeTxn(() async {
      return await _isar.activityModels.put(model);
    });
    // Throw if saved activity's id is different from provided one.
    if (id != model.id) {
      throw DatabaseAccessException();
    }
  }

  /// Delete activity with ID [id] from database.
  /// Throws a [DatabaseAccessException] if something goes wrong
  /// during deletion.
  void deleteActivity(Id id) async {
    final deleted = await _isar.writeTxn(() async {
      return await _isar.activityModels.delete(id);
    });
    if (!deleted) {
      throw DatabaseAccessException();
    }
  }
}
