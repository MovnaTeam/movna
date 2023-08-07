import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:movna/domain/usecases/permission_usecases/get_notification_permission.dart';
import 'package:movna/domain/usecases/permission_usecases/request_notification_permission.dart';

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
class HandleNotificationsPermission
    implements UseCaseAsync<SystemPermissionStatus, void> {
  HandleNotificationsPermission(
    this._getNotificationPermission,
    this._requestNotificationPermission,
  );

  final GetNotificationPermission _getNotificationPermission;
  final RequestNotificationPermission _requestNotificationPermission;

  @override
  Future<Either<Failure, SystemPermissionStatus>> call([void params]) async {
    final notificationPermission = await _getNotificationPermission();
    return await notificationPermission.fold(
      (l) async => Left(l),
      (permission) async {
        if (permission == SystemPermissionStatus.denied) {
          final newPermission = await _requestNotificationPermission();
          return newPermission;
        }
        return Right(permission);
      },
    );
  }
}
