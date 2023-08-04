import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  /// Generic failure.
  ///
  /// Prefer using a more specific failure instead of this one.
  const factory Failure.unknown() = _Unknown;

  /// Generic failure related to a location operation.
  ///
  /// Prefer using a more specific location failure if possible.
  const factory Failure.location() = _Location;

  /// Failure representing an error trying to retrieve the current location.
  ///
  /// If the causing error is a permission error, consider using
  /// [Failure.locationPermission].
  const factory Failure.locationUnavailable() = _LocationUnavailable;

  /// Failure representing an error pertaining to an permission denial trying to
  /// access the location.
  const factory Failure.locationPermission() = _LocationPermission;

  const factory Failure.adapter() = _Adapter;
}
