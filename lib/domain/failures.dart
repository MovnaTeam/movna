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

  /// Failure occurring when the application's document directory could not
  /// be located.
  const factory Failure.documentDirectoryUnavailable() =
      _DocumentDirectoryUnavailable;

  /// Failure representing some databse error, consider using another failure
  /// whenever possible.
  const factory Failure.database() = _Database;

  /// Failure occurring when the database could not be opened.
  const factory Failure.databaseNotOpened() = _DatabaseNotOpened;

  /// Failure occurring when the database could not be closed.
  const factory Failure.databaseNotClosed() = _DatabaseNotClosed;

  /// Failure occurring when something was not successfully saved to database.
  const factory Failure.databaseNotSaved() = _DatabaseNotSaved;

  /// Failure occurring when something was not successfully deleted
  /// from database.
  const factory Failure.databaseNotDeleted() = _DatabaseNotDeleted;
}
