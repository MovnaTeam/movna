import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:movna/domain/usecases/permission_usecases/get_notification_permission.dart';
import 'package:movna/domain/usecases/permission_usecases/request_notification_permission.dart';
import 'package:result_dart/result_dart.dart';

/// Retrieves the [SystemPermissionStatus] of the notification permission.
///
/// If this status is other than [SystemPermissionStatus.permanentlyDenied],
/// shows a dialog for the user to grant the permission and returns the
/// resulting permission status.
///
/// If the initial status is [SystemPermissionStatus.permanentlyDenied] or a
/// granted status to some degree, this usecase only returns the status and does
/// nothing else.
@injectable
class SafeRequestNotificationsPermission
    implements UseCaseAsync<SystemPermissionStatus, void> {
  SafeRequestNotificationsPermission(
    this._getNotificationPermission,
    this._requestNotificationPermission,
  );

  final GetNotificationPermission _getNotificationPermission;
  final RequestNotificationPermission _requestNotificationPermission;

  @override
  Future<Result<SystemPermissionStatus, Fault>> call([void params]) async {
    final notificationPermission = await _getNotificationPermission();
    return await notificationPermission.fold(
      (permission) async {
        if (permission == SystemPermissionStatus.denied) {
          final newPermission = await _requestNotificationPermission();
          return newPermission;
        }
        return Success(permission);
      },
      (f) async => Failure(f),
    );
  }
}
