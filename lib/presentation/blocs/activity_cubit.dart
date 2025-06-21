import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/entities/track_point.dart';
import 'package:movna/domain/entities/track_segment.dart';
import 'package:movna/domain/usecases/save_activity.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';

part 'activity_cubit.freezed.dart';

/// Params to configure the [ActivityCubit].
///
/// An optional [LocationCubit] may be given in order to push new track points
/// to the ongoing activity.
@freezed
abstract class ActivityCubitParams with _$ActivityCubitParams {
  const factory ActivityCubitParams({
    required Sport sport,
    required LocationCubit? locationCubit,
  }) = _ActivityCubitParams;
}

/// A cubit that manages the state of an activity, tracking position and will in
/// the future update the activity and manage pauses.
///
/// Takes in [ActivityCubitParams].
@injectable
class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit(
    @factoryParam this._params,
    this._saveActivity,
  ) : super(const ActivityState.initial()) {
    _initLocationCubitSubscription();
  }

  final SaveActivity _saveActivity;
  final ActivityCubitParams _params;

  late final StreamSubscription<LocationCubitState>? _locationCubitSubscription;

  /// Listens to changes in the [LocationCubit].
  void _initLocationCubitSubscription() {
    _locationCubitSubscription = _params.locationCubit?.stream.listen(
      (locationCubitState) {
        // Called when the service status changes
        if (locationCubitState
            case LocationCubitStateLoaded(:final currentLocation)) {
          _onNewTimedLocation(currentLocation);
        }
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
        emit(
          ActivityState.loaded(
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
      case ActivityLoaded(:final activity):
        final newDistanceInMeters = (activity.distanceInMeters ?? 0) +
            (activity.trackPoints.lastOrNull == null
                ? 0
                : 
            timedLocation.location.gpsCoordinates.distanceToInMeters(
                    activity.trackPoints.last.location!.gpsCoordinates,
                  ));
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
      case ActivityDone():
        break;
    }
  }

  void stopActivity() {
    if (state.activity != null) _saveActivity(state.activity!);
    emit(ActivityState.done());
  }

  Future<void> _closeSubscriptions() async {
    await _locationCubitSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    await _closeSubscriptions();
    return super.close();
  }
}

@freezed
sealed class ActivityState
    with _$ActivityState {
  const ActivityState._();

  const factory ActivityState.loaded({
    required Activity activity,
  }) = ActivityLoaded;

  const factory ActivityState.initial() = ActivityInitial;

  const factory ActivityState.done() = ActivityDone;

  Activity? get activity {
    return switch (this) {
      ActivityLoaded(:final activity) => activity,
      _ => null,
    };
  }
}
