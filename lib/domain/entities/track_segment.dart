import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movna/domain/entities/track_point.dart';

part 'track_segment.freezed.dart';

/// Continuous track segment followed by user, without any pause.
@freezed
class TrackSegment with _$TrackSegment {
  const TrackSegment._();

  const factory TrackSegment({
    /// All track points followed by user.
    @Default([]) List<TrackPoint> trackPoints,
  }) = _TrackSegment;

  /// Starting time of this segment, null if empty.
  DateTime? get startTime {
    return trackPoints.firstOrNull?.timestamp;
  }

  /// Ending time of this segment, null if empty.
  DateTime? get stopTime {
    return trackPoints.lastOrNull?.timestamp;
  }
}
