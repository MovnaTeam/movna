import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/faults.dart';
import 'package:result_dart/result_dart.dart';

abstract class TimedLocationRepository {
  /// Get the last known device location.
  Future<ResultDart<TimedLocation, Fault>> getLastKnownLocation();

  /// Get the current device location.
  Future<ResultDart<TimedLocation, Fault>> getTimedLocation();

  /// Get stream of device locations.
  ///
  /// Specify the foreground notification text using [NotificationConfig].
  Stream<ResultDart<TimedLocation, Fault>> getTimedLocationStream(
    NotificationConfig? notificationConfig,
  );

  Future<ResultDart<LocationServiceStatus, Fault>> getLocationServiceStatus();

  Stream<ResultDart<LocationServiceStatus, Fault>> watchLocationServiceStatus();

  /// Requests that the location service is enabled, this might have different
  /// behavior depending on the underlying platform.
  Future<ResultDart<Unit, Fault>> requestLocationService();
}
