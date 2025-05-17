import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'gps_coordinates.freezed.dart';

/// Position of the device on the globe at a moment.
@freezed
abstract class GpsCoordinates with _$GpsCoordinates {
  const factory GpsCoordinates(
    /// Latitude of position between -180 (excluded) and 180 (included) degrees
    double latitudeInDegrees,

    /// Longitude of position between -90 (included) and 90 (included) degrees
    double longitudeInDegrees,
  ) = _GpsCoordinates;

  const GpsCoordinates._();

  /// The kilometer 0 of french roads (point zero des routes de France)
  static const GpsCoordinates paris = GpsCoordinates(48.85341, 2.3488);

  /// Equator radius in meters (WGS84 ellipsoid).
  static const double equatorRadiusInMeters = 6378137.0;

  /// Polar radius in meters (WGS84 ellipsoid).
  static const double polarRadiusInMeters = 6356752.314245;

  /// Earth approximate radius in meters.
  static const double earthRadiusInMeters =
      (equatorRadiusInMeters + polarRadiusInMeters) / 2;

  double get latitudeInRadians => latitudeInDegrees * pi / 180;

  double get longitudeInRadians => longitudeInDegrees * pi / 180;

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
