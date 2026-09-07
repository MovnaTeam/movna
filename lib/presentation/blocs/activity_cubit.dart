import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/entities/track_point.dart';
import 'package:movna/domain/entities/track_segment.dart';
import 'package:movna/domain/usecases/save_activity.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';

part 'activity_cubit.freezed.dart';

/// A cubit that manages the state of an activity, tracking position and will in
/// the future update the activity and manage pauses.
///
/// Takes in [ActivityCubitParams].
@injectable
class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit(@factoryParam this._locationCubit, this._saveActivity)
    : super(const ActivityState.idle()) {
    _initLocationCubitSubscription();
  }

  final SaveActivity _saveActivity;
  final LocationCubit _locationCubit;

  late final StreamSubscription<LocationCubitState>? _locationCubitSubscription;
  StreamSubscription<DateTime>? _tickerSubscription;

  /// Listens to changes in the [LocationCubit].
  void _initLocationCubitSubscription() {
    _locationCubitSubscription = _locationCubit.stream.listen((
      locationCubitState,
    ) {
      // Called when the service status changes
      if (locationCubitState case LocationCubitStateLoaded(
        :final currentLocation,
      )) {
        _onNewTimedLocation(currentLocation);
      }
    });
  }

  /// Called when a new [timedLocation] is available.
  void _onNewTimedLocation(TimedLocation timedLocation) {
    final newTrackPoint = TrackPoint(
      timestamp: timedLocation.timestamp,
      location: timedLocation.location,
    );
    switch (state) {
      case ActivityOngoing(:final activity):
        final newDistanceInMeters =
            (activity.distanceInMeters ?? 0) +
            (activity.trackPoints.lastOrNull == null
                ? 0
                : timedLocation.location.gpsCoordinates.distanceToInMeters(
                  activity.trackPoints.last.location!.gpsCoordinates,
                ));
        final newMaxSpeed =
            activity.maxSpeedInMetersPerSecond == null
                ? timedLocation.location.speedInMetersPerSecond
                : max(
                  activity.maxSpeedInMetersPerSecond!,
                  timedLocation.location.speedInMetersPerSecond,
                );
        final newDuration = timedLocation.timestamp.difference(
          activity.startTime,
        );
        final newAverageSpeedInMetersPerSecond =
            newDuration.inSeconds != 0
                ? newDistanceInMeters / newDuration.inSeconds
                : timedLocation.location.speedInMetersPerSecond;

        // Create new track segments list by adding the new track point to the
        // last track segment.
        final newTrackSegments =
            activity.trackSegments.isEmpty
                ? [
                  // Should be impossible (first location creates a new segment)
                  TrackSegment(trackPoints: [newTrackPoint]),
                ]
                : [
                  ...List<TrackSegment>.from(
                    activity.trackSegments.getRange(
                      0,
                      activity.trackSegments.length - 1,
                    ),
                  ),
                  activity.trackSegments.last.copyWith(
                    trackPoints: [
                      ...activity.trackSegments.last.trackPoints,
                      newTrackPoint,
                    ],
                  ),
                ];

        emit(
          ActivityState.ongoing(
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
      default:
        break;
    }
  }

  void _listenToDateTime() {
    _tickerSubscription?.cancel();
    _tickerSubscription = Stream.periodic(
      Duration(seconds: 1),
      (i) => DateTime.now(),
    ).listen((now) {
      if (state case ActivityOngoing(:final activity)) {
        // This will need refactor when pause is implemented
        emit(
          ActivityState.ongoing(
            activity: activity.copyWith(
              duration: now.difference(activity.startTime),
            ),
          ),
        );
      }
    });
  }

  void startActivity(Sport sport) {
    _listenToDateTime();
    if (state case ActivityOngoing()) {
      logger.w('Cannot start activity, there is already one ongoing.');
      return;
    }
    emit(
      ActivityState.ongoing(
        activity: Activity(startTime: DateTime.now(), sport: sport),
      ),
    );
  }

  void stopActivity() {
    _closeSubscriptions();
    if (state case ActivityOngoing(:final activity)) {
      emit(
        ActivityState.ongoing(
          activity: activity.copyWith(stopTime: DateTime.now()),
        ),
      );
      _saveActivity(state.activity!);
    }
    emit(ActivityState.idle());
  }

  Future<void> _closeSubscriptions() async {
    await _locationCubitSubscription?.cancel();
    await _tickerSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    await _closeSubscriptions();
    return super.close();
  }
}

@freezed
sealed class ActivityState with _$ActivityState {
  const ActivityState._();

  const factory ActivityState.ongoing({required Activity activity}) =
      ActivityOngoing;

  const factory ActivityState.idle() = ActivityIdle;

  const factory ActivityState.done() = ActivityDone;

  Activity? get activity {
    return switch (this) {
      ActivityOngoing(:final activity) => activity,
      _ => null,
    };
  }
}
