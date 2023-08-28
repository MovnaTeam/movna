import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/usecases/get_last_location.dart';
import 'package:movna/domain/usecases/get_timed_location_stream.dart';
import 'package:movna/presentation/blocs/abstract_location_cubit.dart';
import 'package:movna/presentation/blocs/permissions_cubit.dart';
import 'package:mutex/mutex.dart';
import 'package:result_dart/result_dart.dart';

part 'activity_cubit.freezed.dart';

/// Params to configure the [ActivityCubit].
///
/// Requires a [NotificationConfig] to be specified as this will allow to listen
/// to location while the app is in the background.
///
/// An optional [PermissionsCubit] can be provided to restart a failed location
/// stream on permission change.
@freezed
class ActivityCubitParams with _$ActivityCubitParams {
  const factory ActivityCubitParams({
    required NotificationConfig notificationConfig,
    PermissionsCubit? permissionsCubit,
  }) = _ActivityCubitParams;
}

/// A cubit that manages the state of an activity, tracking position and will in
/// the future update the activity and manage pauses.
///
/// Takes in [ActivityCubitParams].
@injectable
class ActivityCubit extends AbstractLocationCubit<ActivityState> {
  ActivityCubit(
    @factoryParam this._params,
    this._getLastKnownLocation,
    this._getLocationStream,
  ) : super(const ActivityState.initial()) {
    _initPermissionsSubscription();
  }

  final GetLastKnownLocation _getLastKnownLocation;
  final GetLocationStream _getLocationStream;
  final ActivityCubitParams _params;

  StreamSubscription<Result<TimedLocation, Fault>>? _locationSubscription;
  final Mutex _locationSubscriptionMutex = Mutex();

  late final StreamSubscription<PermissionsState>? _permissionsSubscription;

  /// Represents the last location known by this cubit.
  ///
  /// This only concerns memory-persisted location in a small scope and is used
  /// for temporary loss of location such as if the user mistakenly disables
  /// their location service. This does NOT corresponds to the last known
  /// location from a previous session.
  Location? _lastKnownLocation;

  /// Listens to changes in the [PermissionsCubit].
  ///
  /// If a permission changes eventually retry to get the location if the
  /// location stream was on error.
  void _initPermissionsSubscription() {
    _permissionsSubscription = _params.permissionsCubit?.stream.listen(
      (permissionsState) {
        // If the permissions state changes
        permissionsState.mapOrNull(
          loaded: (loadedPermissions) {
            // Location permission is granted
            if (loadedPermissions.locationPermission?.getOrNull()?.isGranted ??
                false) {
              // Current state is error, retry to get location as the cause for
              // error has gone
              state.mapOrNull(
                error: (_) {
                  retryTrackLocation();
                },
              );
            }
          },
        );
      },
    );
  }

  /// Closes the location subscription and restarts it.
  void retryTrackLocation() async {
    await _closeLocationSubscription();
    listenToLocation();
  }

  /// Starts a subscription to the user location using [GetLocationStream].
  ///
  /// Cancels any previous subscription before attempting a new one.
  ///
  /// If the location stream fails, [ActivityState.error] is emitted with
  /// [_lastKnownLocation] set if available.
  ///
  /// Updates [_lastKnownLocation] each time a new location is emitted from the
  /// stream.
  void listenToLocation() {
    emit(ActivityState.loading(lastKnownLocation: _lastKnownLocation));

    // First try to get the last known location, generally faster.
    _getLastKnownLocation().then(
      (result) {
        // Only emit if state is not loaded
        state.maybeMap(
          loaded: (state) {},
          orElse: () {
            result.onSuccess(
              (success) {
                _lastKnownLocation = success.location;
                emit(ActivityState.loading(
                    lastKnownLocation: _lastKnownLocation));
              },
            );
          },
        );
      },
    );

    // Actually listen to location change
    _locationSubscriptionMutex.protect(
      () async {
        if (_locationSubscription != null) {
          await _locationSubscription!.cancel();
        }
        _locationSubscription = _getLocationStream(
          _params.notificationConfig,
        ).listen(
          (locationResult) {
            locationResult.fold(
              (timedLocation) {
                _lastKnownLocation = timedLocation.location;
                emit(
                  ActivityState.loaded(
                    currentLocation: timedLocation.location,
                  ),
                );
              },
              (fault) {
                emit(
                  ActivityState.error(
                    fault: fault,
                    lastKnownLocation: _lastKnownLocation,
                  ),
                );
                _closeLocationSubscription();
              },
            );
          },
          onDone: () {
            _closeLocationSubscription();
          },
        );
      },
    );
  }

  Future<void> _closeLocationSubscription() async {
    await _locationSubscriptionMutex.protect(
      () async {
        await _locationSubscription?.cancel();
        _locationSubscription = null;
      },
    );
  }

  Future<void> _closeSubscriptions() async {
    await _permissionsSubscription?.cancel();
    await _closeLocationSubscription();
  }

  @override
  Future<void> close() async {
    await _closeSubscriptions();
    return super.close();
  }
}

@freezed
class ActivityState with _$ActivityState implements AbstractLocationState {
  const ActivityState._();

  const factory ActivityState.loaded({
    required Location currentLocation,
  }) = _ActivityState;

  const factory ActivityState.loading({
    Location? lastKnownLocation,
  }) = _Loading;

  const factory ActivityState.initial() = _Initial;

  const factory ActivityState.error({
    required Fault fault,
    Location? lastKnownLocation,
  }) = _Error;

  @override
  Fault? get fault {
    return mapOrNull(
      error: (error) => error.fault,
    );
  }

  @override
  Location? get location {
    return map(
      loaded: (loaded) => loaded.currentLocation,
      loading: (loading) => loading.lastKnownLocation,
      error: (error) => error.lastKnownLocation,
      initial: (_) => null,
    );
  }

  @override
  LocationStateType get type {
    return map(
      loaded: (loaded) => LocationStateType.loaded,
      loading: (loading) => LocationStateType.loading,
      error: (error) => LocationStateType.error,
      initial: (_) => LocationStateType.loaded,
    );
  }
}
