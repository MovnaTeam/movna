import 'package:freezed_annotation/freezed_annotation.dart';

part 'faults.freezed.dart';

@freezed
class Fault with _$Fault {
  /// Generic failure.
  ///
  /// Prefer using a more specific failure instead of this one.
  const factory Fault.unknown() = _Unknown;

  /// Generic failure related to a location operation.
  ///
  /// Prefer using a more specific location failure if possible.
  const factory Fault.location() = _Location;

  /// Failure representing an error trying to retrieve the current location.
  ///
  /// If the causing error is a permission error, consider using
  /// [Fault.locationPermission].
  const factory Fault.locationUnavailable() = _LocationUnavailable;

  /// Failure representing an error pertaining to an permission denial trying to
  /// access the location.
  const factory Fault.locationPermission() = _LocationPermission;

  const factory Fault.adapter() = _Adapter;
}
