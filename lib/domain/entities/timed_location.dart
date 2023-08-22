import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movna/domain/entities/location.dart';

part 'timed_location.freezed.dart';

/// Position and movement of the device on the globe at an instant.
@freezed
class TimedLocation with _$TimedLocation {
  const TimedLocation._();

  const factory TimedLocation({
    /// The location and movement of the device.
    required Location location,

    /// The time at which this position was determined.
    required DateTime timestamp,
  }) = _TimedLocation;
}
