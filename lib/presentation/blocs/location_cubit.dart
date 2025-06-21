import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/usecases/get_last_location.dart';
import 'package:movna/domain/usecases/get_timed_location_stream.dart';
import 'package:movna/presentation/blocs/location_service_cubit.dart';
import 'package:movna/presentation/blocs/permissions_cubit.dart';
import 'package:mutex/mutex.dart';
import 'package:result_dart/result_dart.dart';

part 'location_cubit.freezed.dart';

/// Params to configure the [LocationCubit].
///
/// An optional [PermissionsCubit] can be provided to restart a failed location
/// stream on permission change.
@freezed
abstract class LocationCubitParams with _$LocationCubitParams {
  const factory LocationCubitParams({
    NotificationConfig? notificationConfig,
    PermissionsCubit? permissionsCubit,
    LocationServiceCubit? locationServiceCubit,
  }) = _LocationCubitParams;
}

/// A cubit that manages the state of an activity, tracking position and will in
/// the future update the activity and manage pauses.
///
/// Takes in [LocationCubitParams].
@injectable
class LocationCubit extends Cubit<LocationCubitState> {
  LocationCubit(@factoryParam this._params, this._getLastKnownLocation,
      this._getLocationStream)
      : super(const LocationCubitState.initial()) {
    _initPermissionsSubscription();
    _initLocationServiceStatusSubscription();
  }

  final GetLastKnownLocation _getLastKnownLocation;
  final GetLocationStream _getLocationStream;
  final LocationCubitParams _params;

  StreamSubscription<ResultDart<TimedLocation, Fault>>? _locationSubscription;
  final Mutex _locationSubscriptionMutex = Mutex();

  late final StreamSubscription<PermissionsState>? _permissionsSubscription;
  late final StreamSubscription<LocationServiceState>?
      _locationServiceStatusSubscription;

  /// Listens to changes in the [PermissionsCubit].
  ///
  /// If a permission changes eventually retry to get the location if the
  /// location stream was on error.
  void _initPermissionsSubscription() {
    _permissionsSubscription = _params.permissionsCubit?.stream.listen(
      (permissionsState) {
        // If the permissions state changes
        if (permissionsState
            case PermissionsLoaded(:final locationPermission)) {
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
        if (statusState case LocationServiceLoaded(:final status)
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
  /// If the location stream fails, [ActivityState.error] is emitted.
  void listenToLocation() {
    emit(LocationCubitState.loading());

    // First try to get the last known location, generally faster.
    _getLastKnownLocation().then(
      (result) {
        // Only emit if state is not loaded
        switch (state) {
          case LocationCubitStateLoaded():
            break;
          default:
            result.onSuccess(
              (success) {
                emit(
                  LocationCubitState.loading(lastKnownLocation: success),
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
        _locationSubscription = _getLocationStream().listen(
          (locationResult) {
            locationResult.fold(
              (timedLocation) => _onNewTimedLocation(timedLocation),
              (fault) {
                emit(
                  LocationCubitState.error(
                    fault: fault,
                    lastKnownLocation: state.location,
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

  /// Called when a new [timedLocation] is available.
  void _onNewTimedLocation(TimedLocation timedLocation) {
    emit(LocationCubitState.loaded(currentLocation: timedLocation));
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
sealed class LocationCubitState with _$LocationCubitState {
  const LocationCubitState._();

  const factory LocationCubitState.loaded({
    required TimedLocation currentLocation,
  }) = LocationCubitStateLoaded;

  const factory LocationCubitState.loading({
    TimedLocation? lastKnownLocation,
  }) = LocationCubitStateLoading;

  const factory LocationCubitState.initial() = LocationCubitStateInitial;

  const factory LocationCubitState.error(
      {required Fault fault,
      TimedLocation? lastKnownLocation}) = LocationCubitStateError;

  TimedLocation? get location {
    return switch (this) {
      LocationCubitStateLoaded(:final currentLocation) => currentLocation,
      LocationCubitStateLoading(:final lastKnownLocation) => lastKnownLocation,
      LocationCubitStateError(:final lastKnownLocation) => lastKnownLocation,
      _ => null,
    };
  }
}
