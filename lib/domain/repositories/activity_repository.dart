import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/faults.dart';
import 'package:result_dart/result_dart.dart';

abstract class ActivityRepository {
  /// Save given [activity] to the device storage.
  Future<Result<Unit, Fault>> saveActivity(Activity activity);

  /// Delete an [activity] from the device storage.
  Future<Result<Unit, Fault>> deleteActivity(Activity activity);

  /// Get all activities stored on the device.
  Future<Result<List<Activity>, Fault>> getActivities();
}
