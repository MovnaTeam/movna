import 'package:dartz/dartz.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/failures.dart';

abstract class ActivityRepository {
  /// Save given [activity] to the device storage.
  Future<Either<Failure, void>> saveActivity(Activity activity);

  /// Delete an [activity] from the device storage.
  Future<Either<Failure, void>> deleteActivity(Activity activity);

  /// Get all activities stored on the device.
  Future<Either<Failure, List<Activity>>> getActivities();
}
