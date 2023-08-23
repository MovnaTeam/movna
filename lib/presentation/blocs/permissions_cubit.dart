import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/system_permission.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/usecases/permission_usecases/get_location_permission.dart';
import 'package:movna/domain/usecases/permission_usecases/get_notification_permission.dart';
import 'package:movna/domain/usecases/permission_usecases/request_location_permission.dart';
import 'package:movna/domain/usecases/permission_usecases/request_notification_permission.dart';
import 'package:movna/domain/usecases/permission_usecases/should_request_location_permission.dart';
import 'package:movna/domain/usecases/permission_usecases/should_request_notifications_permission.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:result_dart/result_dart.dart';

part 'permissions_cubit.freezed.dart';

/// Data class to specify to [PermissionsCubit] which permissions to query.
@freezed
class PermissionsCubitParams with _$PermissionsCubitParams {
  const factory PermissionsCubitParams({
    @Default(false) bool requestNotifications,
    @Default(false) bool requestLocation,
  }) = _PermissionsCubitParams;
}

/// A cubit that manages permissions requests.
///
/// Takes in [PermissionsCubitParams] to specify which permissions should be
/// requested.
///
/// Always emits [PermissionsState.loaded] state when [requestPermissions]
/// terminates but the loaded state might contain [Failure]s, see the state's
/// documentation for more details.
@injectable
class PermissionsCubit extends Cubit<PermissionsState> {
  PermissionsCubit(
    @factoryParam this._params,
    this._getNotificationPermission,
    this._getLocationPermission,
    this._requestLocationPermission,
    this._requestNotificationPermission,
    this._shouldRequestLocationPermission,
    this._shouldRequestNotificationsPermission,
  ) : super(const PermissionsState.initial());

  final GetNotificationPermission _getNotificationPermission;
  final GetLocationPermission _getLocationPermission;
  final RequestLocationPermission _requestLocationPermission;
  final RequestNotificationPermission _requestNotificationPermission;
  final ShouldRequestLocationPermission _shouldRequestLocationPermission;
  final ShouldRequestNotificationsPermission
      _shouldRequestNotificationsPermission;
  final PermissionsCubitParams _params;

  /// Checks the permissions given by [_params] except if [overrideParams] are
  /// not null.
  /// If [overrideParams] are not null, they are used instead of [_params].
  ///
  /// If [silent] is true then the only the final [PermissionsState.loaded] is
  /// emitted and [PermissionsState.loading] is not emitted. Set this to `true`
  /// to avoid loading indicators in the UI.
  ///
  /// This only checks the permissions and does not request them.
  /// Use [requestPermissions] to request the permissions.
  void checkPermissions([
    PermissionsCubitParams? overrideParams,
    bool silent = false,
  ]) async {
    if (!silent) {
      emit(const PermissionsState.loading());
    }
    final paramsToUse = overrideParams ?? _params;

    Result<SystemPermissionStatus, Fault>? notificationPermission;
    Result<SystemPermissionStatus, Fault>? locationPermission;

    if (paramsToUse.requestNotifications) {
      notificationPermission = await _getNotificationPermission();
    }
    if (paramsToUse.requestLocation) {
      locationPermission = await _getLocationPermission();
    }
    // Permission request might depend on user input so check cubit is not
    // closed before emitting.
    if (!isClosed) {
      emitState(notificationPermission, locationPermission);
    }
  }

  /// Requests permissions.
  ///
  /// This method requests the permissions specified by [_params] or
  /// [overrideParams] if not `null`.
  ///
  /// This method emits a [PermissionsState.loaded] state with the status of
  /// the requested permissions.
  ///
  /// If [silent] is true then the only the final [PermissionsState.loaded] is
  /// emitted and [PermissionsState.loading] is not emitted. Set this to `true`
  /// to avoid loading indicators in the UI.
  ///
  /// This method prompts the user so that they can grant the permissions.
  /// Use [checkPermissions] to silently check the permissions' status.
  void requestPermissions([
    PermissionsCubitParams? overrideParams,
    bool silent = false,
  ]) async {
    if (!silent) {
      emit(const PermissionsState.loading());
    }
    Result<SystemPermissionStatus, Fault>? notificationPermission;
    Result<SystemPermissionStatus, Fault>? locationPermission;
    final paramsToUse = overrideParams ?? _params;

    if (paramsToUse.requestNotifications) {
      notificationPermission = await _requestNotificationPermission();
    }
    if (paramsToUse.requestLocation) {
      locationPermission = await _requestLocationPermission();
    }
    // Permission request might depend on user input so check cubit is not
    // closed before emitting.
    if (!isClosed) {
      emitState(notificationPermission, locationPermission);
    }
  }

  /// Returns a function that specifies which method should be used to request
  /// the notifications permission.
  ///
  /// Returns either [requestPermissions] with override params to only request
  /// notification permission or [openAppSettings] depending on the result of
  /// [ShouldRequestNotificationsPermission].
  ///
  /// See [getLocationRequestMethod] for the location equivalent.
  Future<Function> getNotificationRequestMethod([bool silent = false]) async {
    final result = await _shouldRequestNotificationsPermission();
    final shouldShowRationale = result.getOrDefault(false);
    return shouldShowRationale
        ? () => requestPermissions(
              const PermissionsCubitParams(requestNotifications: true),
              silent,
            )
        : openAppSettings;
  }

  /// Returns a function that specifies which method should be used to request
  /// the location permission.
  ///
  /// Returns either [requestPermissions] with override params to only request
  /// location permission or [openAppSettings] depending on the result of
  /// [ShouldRequestLocationPermission].
  ///
  /// See [getNotificationRequestMethod] for the notifications equivalent.
  Future<Function> getLocationRequestMethod([bool silent = false]) async {
    final result = await _shouldRequestLocationPermission();
    final shouldShowRationale = result.getOrDefault(false);
    return shouldShowRationale
        ? () => requestPermissions(
              const PermissionsCubitParams(requestLocation: true),
              silent,
            )
        : openAppSettings;
  }

  /// Emits a [PermissionsState.loaded] state with the given [notification] and
  /// [location] [SystemPermissionStatusHolder]s.
  ///
  /// If [notification] is `null` then the current notification holder will be
  /// used or [SystemPermissionStatusHolder.notDemanded] if no current
  /// holder exists.
  ///
  /// If [location] is `null` then the current location holder will be
  /// used or [SystemPermissionStatusHolder.notDemanded] if no current
  /// holder exists.
  void emitState(
    Result<SystemPermissionStatus, Fault>? notification,
    Result<SystemPermissionStatus, Fault>? location,
  ) async {
    state.maybeMap(
      loaded: (loaded) {
        emit(
          loaded.copyWith(
            locationPermission: location ?? loaded.notificationPermission,
            notificationPermission:
                notification ?? loaded.notificationPermission,
          ),
        );
      },
      orElse: () {
        emit(
          PermissionsState.loaded(
            notificationPermission: notification,
            locationPermission: location,
          ),
        );
      },
    );
  }
}

@freezed
class PermissionsState with _$PermissionsState {
  /// Contains the status of notification and location permissions.
  ///
  /// The [SystemPermissionStatus] is wrapped in a
  /// [SystemPermissionStatusHolder].
  ///
  /// The holder contains data as whether or not the permission was actually
  /// queried.
  /// On query success [SystemPermissionStatusHolder.status] contains
  /// the query result.
  /// On failure [SystemPermissionStatusHolder.failure] contains
  /// the failure's reason.
  const factory PermissionsState.loaded({
    required Result<SystemPermissionStatus, Fault>? notificationPermission,
    required Result<SystemPermissionStatus, Fault>? locationPermission,
  }) = _Loaded;

  const factory PermissionsState.loading() = _Loading;

  const factory PermissionsState.initial() = _Initial;
}
