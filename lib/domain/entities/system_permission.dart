import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movna/domain/faults.dart';

part 'system_permission.freezed.dart';

enum SystemPermissionStatus {
  always,
  denied,
  whileInUse,
  permanentlyDenied;

  bool get isGranted => switch (this) {
        SystemPermissionStatus.always => true,
        SystemPermissionStatus.whileInUse => true,
        _ => false,
      };
}

/// Data class containing a [SystemPermissionStatus] as well as a boolean
/// indicating if permission was requested or not.
///
/// [demanded] represents the business logic need of the permission.
///
/// If [demanded] is `true` then [status] should not be null.
/// if [failure] is not null and [demanded] is true then it means an error
/// occurred while getting the permission.
@freezed
class SystemPermissionStatusHolder with _$SystemPermissionStatusHolder {
  const factory SystemPermissionStatusHolder({
    required bool demanded,
    SystemPermissionStatus? status,
    Fault? fault,
  }) = _SystemPermissionHolder;

  static const SystemPermissionStatusHolder notDemanded =
      SystemPermissionStatusHolder(
    demanded: false,
  );
}
