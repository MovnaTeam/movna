import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movna/domain/entities/location.dart';

part 'track_point.freezed.dart';

/// A point crossed by user at an instant, with associated data.
@freezed
class TrackPoint with _$TrackPoint {
  const TrackPoint._();

  const factory TrackPoint({
    /// Location with movement data and timestamp.
    Location? location,

    /// User's Heart Beat in Beats Per Minute.
    double? heartBeatPerMinute,
  }) = _TrackPoint;
}
