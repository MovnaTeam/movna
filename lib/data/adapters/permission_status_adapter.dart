import 'package:injectable/injectable.dart';
import 'package:movna/data/adapters/base_adapter.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:permission_handler/permission_handler.dart';

@injectable
class PermissionStatusAdapter
    extends BaseAdapter<SystemPermissionStatus, PermissionStatus> {
  @override
  SystemPermissionStatus modelToEntity(PermissionStatus m) {
    return switch (m) {
      PermissionStatus.denied => SystemPermissionStatus.denied,
      PermissionStatus.permanentlyDenied =>
        SystemPermissionStatus.permanentlyDenied,
      PermissionStatus.restricted => SystemPermissionStatus.denied,
      PermissionStatus.limited => SystemPermissionStatus.whileInUse,
      PermissionStatus.provisional => SystemPermissionStatus.whileInUse,
      PermissionStatus.granted => SystemPermissionStatus.always,
    };
  }
}
