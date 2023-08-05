import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movna/core/unit_conversion.dart';

part 'gps_coordinates.freezed.dart';

/// Position of the device on the globe at a moment.
@freezed
class GpsCoordinates with _$GpsCoordinates {
  const factory GpsCoordinates(
    /// Latitude of position between -180 (excluded) and 180 (included) degrees
    double latitudeInDegrees,

    /// Longitude of position between -90 (included) and 90 (included) degrees
    double longitudeInDegrees,
  ) = _GpsCoordinates;
  const GpsCoordinates._();

  /// Equator radius in meters (WGS84 ellipsoid).
  static const double equatorRadiusInMeters = 6378137.0;

  /// Polar radius in meters (WGS84 ellipsoid).
  static const double polarRadiusInMeters = 6356752.314245;

  /// Earth approximate radius in meters.
  static const double earthRadiusInMeters =
      (equatorRadiusInMeters + polarRadiusInMeters) / 2;

  double get latitudeInRadians => degreesToRadians(latitudeInDegrees);

  double get longitudeInRadians => degreesToRadians(longitudeInDegrees);

  /// Computes distance in meters between this position and [other] position,
  /// using Haversine formula.
  double distanceToInMeters(GpsCoordinates other) {
    final sinDeltaLatitude =
        sin((other.latitudeInRadians - latitudeInRadians) / 2);
    final sinDeltaLongitude =
        sin((other.longitudeInRadians - longitudeInRadians) / 2);

    /// Mathematical variable, does not mean anything by itself.
    /// See Haversine formula.
    final double a = sinDeltaLatitude * sinDeltaLatitude +
        sinDeltaLongitude *
            sinDeltaLongitude *
            cos(latitudeInRadians) *
            cos(other.latitudeInRadians);

    return earthRadiusInMeters * 2 * atan2(sqrt(a), sqrt(1.0 - a));
  }
}
