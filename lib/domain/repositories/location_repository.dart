import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/faults.dart';
import 'package:result_dart/result_dart.dart';

abstract class LocationRepository {
  /// Get the current device location.
  Future<Result<Location, Fault>> getLocation();

  /// Get stream of device locations.
  ///
  /// Specify the foreground notification text using [NotificationConfig]
  Stream<Result<Location, Fault>> getLocationStream(
    NotificationConfig notificationConfig,
  );

  Future<Result<LocationServiceStatus, Fault>> getLocationServiceStatus();

  /// Requests that the location service is enabled, this might have different
  /// behavior depending on the underlying platform.
  Future<Result<Unit, Fault>> requestLocationService();
}
