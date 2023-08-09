import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:movna/domain/usecases/permission_usecases/get_location_permission.dart';
import 'package:movna/domain/usecases/permission_usecases/request_location_permission.dart';

/// Retrieves the [SystemPermissionStatus] of the location permission.
///
/// If this status is other than [SystemPermissionStatus.permanentlyDenied],
/// shows a dialog for the user to grant the permission and returns the
/// resulting permission status.
///
/// If the initial status is [SystemPermissionStatus.permanentlyDenied] or a
/// granted status to some degree, this usecase only returns the status and does
/// nothing else.
@injectable
class SafeRequestLocationPermission
    implements UseCaseAsync<SystemPermissionStatus, void> {
  SafeRequestLocationPermission(
    this._getLocationPermission,
    this._requestLocationPermission,
  );

  final GetLocationPermission _getLocationPermission;
  final RequestLocationPermission _requestLocationPermission;

  @override
  Future<Either<Failure, SystemPermissionStatus>> call([void params]) async {
    final locationPermission = await _getLocationPermission();
    return await locationPermission.fold(
      (l) => Left(l),
      (permission) async {
        if (permission == SystemPermissionStatus.denied) {
          final newPermission = await _requestLocationPermission();
          return newPermission;
        }
        return Right(permission);
      },
    );
  }
}
