import 'package:injectable/injectable.dart';
import 'package:movna/core/modules/drift_module.dart';
import 'package:movna/data/datasources/drift_database.dart';
import 'package:movna/data/exceptions.dart';

@injectable
class DriftDataBaseSource {
  DriftDataBaseSource(@baseDrift this._database);

  final AppDriftDatabase _database;

  /// Returns activity models sorted by start time.
  Future<List<ActivityDriftModel>> getActivities() async {
    return await _database.select(_database.activityDriftModels).get();
  }

  /// Save activity to database.
  /// Throws a [DatabaseAccessException] if something goes wrong.
  void saveActivity(ActivityDriftModel model) async {
    await _database.into(_database.activityDriftModels).insert(model);
  }

  /// Delete activity with ID [id] from database.
  /// Throws a [DatabaseAccessException] if something goes wrong
  /// during deletion.
  void deleteActivity(String id) async {
    (_database.delete(_database.activityDriftModels)
          ..where((e) => e.id.equals(id)))
        .go();
  }
}
