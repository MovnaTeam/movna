import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';

part 'location.freezed.dart';

/// Position of the device on the globe at a moment.
@freezed
class Location with _$Location {
  const Location._();

  const factory Location({
    /// GPS coordinates.
    @Default(GpsCoordinates(0, 0)) GpsCoordinates gpsCoordinates,

    /// The altitude of the device in meters.
    @Default(0) double altitudeInMeters,

    /// The estimated horizontal error of the position in meters.
    @Default(0) double errorInMeters,

    /// The heading in which the device is traveling in degrees.
    @Default(0) double headingInDegrees,

    /// The speed at which the devices is traveling in meters per second over
    /// the ground.
    @Default(0) double speedInMetersPerSecond,

    /// The estimated speed error of this position, in meters per second.
    @Default(0) double speedErrorInMetersPerSecond,

    /// The time at which this position was determined.
    DateTime? timestamp,
  }) = _Location;
}
