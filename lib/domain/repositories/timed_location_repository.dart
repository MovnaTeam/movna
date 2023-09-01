import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/faults.dart';
import 'package:result_dart/result_dart.dart';

abstract class TimedLocationRepository {
  /// Get the last known device location.
  Future<Result<TimedLocation, Fault>> getLastKnownLocation();

  /// Get the current device location.
  Future<Result<TimedLocation, Fault>> getTimedLocation();

  /// Get stream of device locations.
  ///
  /// Specify the foreground notification text using [NotificationConfig]
  Stream<Result<TimedLocation, Fault>> getTimedLocationStream(
    NotificationConfig notificationConfig,
  );

  Future<Result<LocationServiceStatus, Fault>> getLocationServiceStatus();

  /// Requests that the location service is enabled, this might have different
  /// behavior depending on the underlying platform.
  Future<Result<Unit, Fault>> requestLocationService();
}
