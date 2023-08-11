import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/domain/entities/track_point.dart';
import 'package:movna/domain/entities/track_segment.dart';

part 'activity.freezed.dart';

/// Training activity session.
@freezed
class Activity with _$Activity {
  const Activity._();

  const factory Activity({
    /// The time at which this activity begun.
    required DateTime startTime,

    /// The time at which this activity ended.
    /// Null while activity has not ended.
    DateTime? stopTime,

    /// The sport practiced during this activity.
    /// Null when not specified by user.
    Sport? sport,

    /// The name of this activity.
    /// Null when not specified by user.
    String? name,

    /// The total distance traveled during this activity in meters.
    /// Null when info is not available.
    double? distanceInMeters,

    /// The total duration of this activity, removed pauses durations.
    /// Null when info is not available.
    ///
    /// If an activity starts at 15h, is paused between 15h30 and 15h45 and
    /// stopped at 16h, the [duration] is 45 minutes.
    Duration? duration,

    /// The maximum speed reached during this activity in meters per second.
    double? maxSpeedInMetersPerSecond,

    /// The average speed during this activity in meters per second.
    double? averageSpeedInMetersPerSecond,

    /// The average heart beat during this activity in Beats Per Minute.
    /// Null when not specified by user.
    double? averageHeartBeatPerMinute,

    /// Additional user notes about this activity.
    String? notes,

    /// The activity continuous track segments,
    /// with a pause between each segment.
    ///
    /// Can be empty when activity was imported or created manually.
    @Default([]) List<TrackSegment> trackSegments,
  }) = _Activity;

  List<TrackPoint> get trackPoints {
    return trackSegments.expand((segment) => segment.trackPoints).toList();
  }
}
