import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/usecases/get_last_location.dart';
import 'package:movna/domain/usecases/get_timed_location_stream.dart';
import 'package:movna/presentation/blocs/abstract_location_cubit.dart';
import 'package:movna/presentation/blocs/location_service_cubit.dart' as l;
import 'package:movna/presentation/blocs/permissions_cubit.dart' as p;
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
abstract class ActivityCubitParams with _$ActivityCubitParams {
  const factory ActivityCubitParams({
    required NotificationConfig notificationConfig,
    p.PermissionsCubit? permissionsCubit,
    l.LocationServiceCubit? locationServiceCubit,
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
    _initLocationServiceStatusSubscription();
  }

  final GetLastKnownLocation _getLastKnownLocation;
  final GetLocationStream _getLocationStream;
  final ActivityCubitParams _params;

  StreamSubscription<ResultDart<TimedLocation, Fault>>? _locationSubscription;
  final Mutex _locationSubscriptionMutex = Mutex();

  late final StreamSubscription<p.PermissionsState>? _permissionsSubscription;
  late final StreamSubscription<l.LocationServiceState>?
      _locationServiceStatusSubscription;

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
        if (permissionsState case p.Loaded(:final locationPermission)) {
          if (locationPermission?.getOrNull()?.isGranted ?? false) {
            // Current state is error, retry to get location as the cause for
            // error has gone
            if (state case Error()) {
              retryTrackLocation();
            }
          }
        }
      },
    );
  }

  /// Listens to changes in the [LocationServiceCubit].
  ///
  /// If a the service status changes eventually retry to get the location if
  /// the location stream was on error.
  void _initLocationServiceStatusSubscription() {
    _locationServiceStatusSubscription =
        _params.locationServiceCubit?.stream.listen(
      (statusState) {
        // Called when the service status changes
        if (statusState case l.Loaded(:final status)
            when status == LocationServiceStatus.enabled) {
            // Current state is error, retry to get location as the cause for
            // the error has gone
            if (state case Error()) {
              retryTrackLocation();
            }
          
        }
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
        switch (state) {
          case Loaded():
            break;
          default:
            result.onSuccess(
              (success) {
                _lastKnownLocation = success.location;
                emit(
                  ActivityState.loading(lastKnownLocation: _lastKnownLocation),
                );
              },
            );
            break;
        }
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
    await _locationServiceStatusSubscription?.cancel();
    await _closeLocationSubscription();
  }

  @override
  Future<void> close() async {
    await _closeSubscriptions();
    return super.close();
  }
}

@freezed
sealed class ActivityState
    with _$ActivityState
    implements AbstractLocationState {
  const ActivityState._();

  const factory ActivityState.loaded({
    required Location currentLocation,
  }) = Loaded;

  const factory ActivityState.loading({
    Location? lastKnownLocation,
  }) = Loading;

  const factory ActivityState.initial() = Initial;

  const factory ActivityState.error({
    required Fault fault,
    Location? lastKnownLocation,
  }) = Error;

  @override
  Fault? get fault {
    if (this case Error(:final fault)) {
      return fault;
    }
    return null;
  }

  @override
  Location? get location {
    switch (this) {
      case Loaded(:final currentLocation):
        return currentLocation;
      case Loading(:final lastKnownLocation):
        return lastKnownLocation;
      case Error(:final lastKnownLocation):
        return lastKnownLocation;
      case Initial():
        return null;
    }
  }

  @override
  LocationStateType get type {
    switch (this) {
      case Loaded():
        return LocationStateType.loaded;
      case Loading():
        return LocationStateType.loading;
      case Error():
        return LocationStateType.error;
      case Initial():
        return LocationStateType.loaded;
    }
  }
}
