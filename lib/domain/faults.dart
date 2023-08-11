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

  /// Failure occurring when the application's document directory could not
  /// be located.
  const factory Fault.documentDirectoryUnavailable() =
      _DocumentDirectoryUnavailable;

  /// Failure representing some databse error, consider using another failure
  /// whenever possible.
  const factory Fault.database() = _Database;

  /// Failure occurring when the database could not be opened.
  const factory Fault.databaseNotOpened() = _DatabaseNotOpened;

  /// Failure occurring when the database could not be closed.
  const factory Fault.databaseNotClosed() = _DatabaseNotClosed;

  /// Failure occurring when something was not successfully saved to database.
  const factory Fault.databaseNotSaved() = _DatabaseNotSaved;

  /// Failure occurring when something was not successfully deleted
  /// from database.
  const factory Fault.databaseNotDeleted() = _DatabaseNotDeleted;
}
