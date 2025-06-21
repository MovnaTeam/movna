import 'dart:async';
import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/entities/track_point.dart';
import 'package:movna/domain/entities/track_segment.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/usecases/get_last_location.dart';
import 'package:movna/domain/usecases/get_timed_location_stream.dart';
import 'package:movna/domain/usecases/save_activity.dart';
import 'package:movna/presentation/blocs/abstract_location_cubit.dart';
import 'package:movna/presentation/blocs/location_service_cubit.dart';
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
abstract class ActivityCubitParams with _$ActivityCubitParams {
  const factory ActivityCubitParams({
    required Sport sport,
    required NotificationConfig notificationConfig,
    PermissionsCubit? permissionsCubit,
    LocationServiceCubit? locationServiceCubit,
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
    this._saveActivity,
  ) : super(const ActivityState.initial()) {
    _initPermissionsSubscription();
    _initLocationServiceStatusSubscription();
  }

  final GetLastKnownLocation _getLastKnownLocation;
  final GetLocationStream _getLocationStream;
  final SaveActivity _saveActivity;
  final ActivityCubitParams _params;

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
    emit(ActivityState.loading());

    // First try to get the last known location, generally faster.
    _getLastKnownLocation().then(
      (result) {
        // Only emit if state is not loaded
        switch (state) {
          case ActivityLoaded():
            break;
          default:
            result.onSuccess(
              (success) {
                emit(
                  ActivityState.loading(lastKnownLocation: success.location),
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
              (timedLocation) => _onNewTimedLocation(timedLocation),
              (fault) {
                emit(
                  ActivityState.error(
                    fault: fault,
                    lastKnownLocation: state.location,
                    activity: state.activity,
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
    final newTrackPoint = TrackPoint(
      timestamp: timedLocation.timestamp,
      location: timedLocation.location,
    );
    switch (state) {
      case ActivityInitial():
      case ActivityLoading():
        emit(
          ActivityState.loaded(
            currentLocation: timedLocation.location,
            activity: Activity(
              startTime: timedLocation.timestamp,
              sport: _params.sport,
              trackSegments: [
                TrackSegment(trackPoints: [newTrackPoint]),
              ],
            ),
          ),
        );
        break;
      case ActivityLoaded(:final activity, :final currentLocation):
        final newDistanceInMeters = (activity.distanceInMeters ?? 0) +
            timedLocation.location.gpsCoordinates.distanceToInMeters(
              currentLocation.gpsCoordinates,
            );
        final newMaxSpeed = activity.maxSpeedInMetersPerSecond == null
            ? timedLocation.location.speedInMetersPerSecond
            : max(
                activity.maxSpeedInMetersPerSecond!,
                timedLocation.location.speedInMetersPerSecond,
              );
        final newDuration =
            timedLocation.timestamp.difference(activity.startTime);
        final newAverageSpeedInMetersPerSecond =
            newDistanceInMeters / newDuration.inSeconds;

        // Create new track segments list by adding the new track point to the
        // last track segment.
        final newTrackSegments = activity.trackSegments.isEmpty
            ? [
                // Should be impossible (first location creates a new segment)
                TrackSegment(trackPoints: [newTrackPoint]),
              ]
            : [
                ...List<TrackSegment>.from(
                  activity.trackSegments
                      .getRange(0, activity.trackSegments.length - 1),
                ),
                activity.trackSegments.last.copyWith(
                  trackPoints: [
                    ...activity.trackSegments.last.trackPoints,
                    newTrackPoint,
                  ],
                ),
              ];

        emit(
          ActivityState.loaded(
            currentLocation: timedLocation.location,
            activity: activity.copyWith(
              distanceInMeters: newDistanceInMeters,
              maxSpeedInMetersPerSecond: newMaxSpeed,
              duration: newDuration,
              averageSpeedInMetersPerSecond: newAverageSpeedInMetersPerSecond,
              trackSegments: newTrackSegments,
            ),
          ),
        );
        break;
      case ActivityError(activity: final previousActivity):
        final activity =
            previousActivity ?? Activity(startTime: timedLocation.timestamp);
        final newMaxSpeed = activity.maxSpeedInMetersPerSecond == null
            ? timedLocation.location.speedInMetersPerSecond
            : max(
                activity.maxSpeedInMetersPerSecond!,
                timedLocation.location.speedInMetersPerSecond,
              );
        final newDuration =
            timedLocation.timestamp.difference(activity.startTime);
        final newAverageSpeedInMetersPerSecond =
            (activity.distanceInMeters ?? 0) / newDuration.inSeconds;

        var newTrackSegments = activity.trackSegments.isEmpty
            ? [
                TrackSegment(),
              ]
            : activity.trackSegments;
        newTrackSegments.last.trackPoints.add(newTrackPoint);

        emit(
          ActivityState.loaded(
            currentLocation: timedLocation.location,
            activity: activity.copyWith(
              maxSpeedInMetersPerSecond: newMaxSpeed,
              duration: newDuration,
              averageSpeedInMetersPerSecond: newAverageSpeedInMetersPerSecond,
              trackSegments: newTrackSegments,
            ),
          ),
        );
        break;
      case ActivityDone():
        break;
    }
  }

  void stopActivity() {
    if (state.activity != null) _saveActivity(state.activity!);
    emit(ActivityState.done());
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
    required Activity activity,
  }) = ActivityLoaded;

  const factory ActivityState.loading({
    Location? lastKnownLocation,
  }) = ActivityLoading;

  const factory ActivityState.initial() = ActivityInitial;

  const factory ActivityState.error({
    required Fault fault,
    Location? lastKnownLocation,
    Activity? activity,
  }) = ActivityError;

  const factory ActivityState.done() = ActivityDone;

  @override
  Fault? get fault {
    if (this case ActivityError(:final fault)) {
      return fault;
    }
    return null;
  }

  @override
  Location? get location {
    return switch (this) {
      ActivityLoaded(:final currentLocation) => currentLocation,
      ActivityLoading(:final lastKnownLocation) => lastKnownLocation,
      ActivityError(:final lastKnownLocation) => lastKnownLocation,
      _ => null,
    };
  }

  Activity? get activity {
    return switch (this) {
      ActivityLoaded(:final activity) => activity,
      ActivityError(:final activity) => activity,
      _ => null,
    };
  }

  @override
  LocationStateType get type {
    return switch (this) {
      ActivityLoaded() => LocationStateType.loaded,
      ActivityLoading() => LocationStateType.loading,
      ActivityError() => LocationStateType.error,
      ActivityInitial() => LocationStateType.loaded,
      ActivityDone() => LocationStateType.done,
    };
  }
}
