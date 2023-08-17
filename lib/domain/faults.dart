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

  /// Failure occurring when an entity could not be recovered from its source.
  const factory Fault.entityNotSourced() = _DatabaseNotSaved;

  /// Failure occurring when an entity was not successfully saved.
  const factory Fault.entityNotSaved() = _DatabaseNotSaved;

  /// Failure occurring when an entity was not successfully deleted.
  const factory Fault.entityNotDeleted() = _DatabaseNotDeleted;
}
