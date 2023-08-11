import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:movna/core/modules/isar_module.dart';
import 'package:movna/data/models/activity_model.dart';

@injectable
class IsarDataBaseSource {
  IsarDataBaseSource(@baseIsar this._isar);

  final Isar _isar;

  /// Returns activity models sorted by start time.
  Future<List<ActivityModel>> getActivities() async {
    return await _isar.activityModels.where().sortByStartTimeDesc().findAll();
  }

  /// Save activity to database. Returns the unique ID of the saved object.
  /// This returned Id should match the one of the given object.
  Future<Id> saveActivity(ActivityModel model) async {
    final id = await _isar.writeTxn(() async {
      return await _isar.activityModels.put(model);
    });
    return id;
  }

  /// Delete activity with ID [id] from database.
  /// Returns whether the activity was successfully deleted or not :
  /// true when deleted.
  Future<bool> deleteActivity(Id id) async {
    final deleted = await _isar.writeTxn(() async {
      return await _isar.activityModels.delete(id);
    });
    return deleted;
  }
}
