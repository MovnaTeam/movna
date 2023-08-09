import 'package:dartz/dartz.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/failures.dart';

abstract class LocationRepository {
  /// Get the current device location.
  Future<Either<Failure, Location>> getLocation();

  /// Get stream of device locations.
  ///
  /// Specify the foreground notification text using [NotificationConfig]
  Stream<Either<Failure, Location>> getLocationStream(
    NotificationConfig notificationConfig,
  );

  Future<Either<Failure, LocationServiceStatus>> getLocationServiceStatus();

  /// Requests that the location service is enabled, this might have different
  /// behavior depending on the underlying platform.
  Future<Either<Failure, void>> requestLocationService();
}
