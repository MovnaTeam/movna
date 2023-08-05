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
    /// Null when activity is not ended yet.
    DateTime? stopTime,

    /// The sport practiced during this activity. Can be unspecified.
    Sport? sport,

    /// The name of this activity. Can be unspecified.
    String? name,

    /// The total distance traveled during this activity in meters.
    @Default(0) double distanceInMeters,

    /// The total duration of this activity, accounting for pauses.
    @Default(Duration.zero) Duration duration,

    /// The maximum speed reached during this activity in meters per second.
    @Default(0) double maxSpeedInMetersPerSecond,

    /// The average speed during this activity in meters per second.
    @Default(0) double averageSpeedInMetersPerSecond,

    /// The average heart beat during this activity in Beats Per Minute.
    /// Can be unspecified.
    double? averageHeartBeatPerMinute,

    /// Additional user notes about this activity.
    /// Can be empty.
    @Default('') String notes,

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
