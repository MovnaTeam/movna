import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'position.freezed.dart';

/// Position of the device on the globe at a moment.
@freezed
class Position with _$Position {
  const Position._();

  const factory Position({
    /// Latitude of position between -180 (excluded) and 180 (included) degrees
    required double latitudeInDegrees,

    /// Longitude of position between -90 (included) and 90 (included) degrees
    required double longitudeInDegrees,

    /// The altitude of the device in meters.
    @Default(0) double altitudeInMeters,

    /// The estimated horizontal accuracy of the position in meters.
    @Default(0) double accuracyInMeters,

    /// The heading in which the device is traveling in degrees.
    @Default(0) double headingInDegrees,

    /// The speed at which the devices is traveling in meters per second over
    /// the ground.
    @Default(0) double speedInMetersPerSecond,

    /// The estimated speed accuracy of this position, in meters per second.
    @Default(0) double speedAccuracyInMetersPerSecond,

    /// The time at which this position was determined.
    DateTime? timestamp,
  }) = _Position;

  /// Equator radius in meters (WGS84 ellipsoid).
  static const double equatorRadiusInMeters = 6378137.0;

  /// Polar radius in meters (WGS84 ellipsoid).
  static const double polarRadiusInMeters = 6356752.314245;

  /// Earth approximate radius in meters.
  static const double earthRadiusInMeters =
      (equatorRadiusInMeters + polarRadiusInMeters) / 2;

  double get latitudeInRadiant => latitudeInDegrees * pi / 180;

  double get longitudeInRadiant => longitudeInDegrees * pi / 180;

  /// Computes distance in meters between this position and [other] position,
  /// using Haversine formula.
  double distanceToInMeters(Position other) {
    final sinDeltaLatitude =
        sin((other.latitudeInRadiant - latitudeInRadiant) / 2);
    final sinDeltaLongitude =
        sin((other.longitudeInRadiant - longitudeInRadiant) / 2);

    final double a = sinDeltaLatitude * sinDeltaLatitude +
        sinDeltaLongitude *
            sinDeltaLongitude *
            cos(latitudeInRadiant) *
            cos(other.latitudeInRadiant);

    return earthRadiusInMeters * 2 * atan2(sqrt(a), sqrt(1.0 - a));

    // TODO : take into account altitude if available (pythagorean)
  }
}
