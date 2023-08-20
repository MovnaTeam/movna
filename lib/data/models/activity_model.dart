import 'package:isar/isar.dart';
import 'package:movna/domain/entities/sport.dart';

part 'activity_model.g.dart';

@Collection()
class ActivityModel {
  /// Use startTime as unique identifier.
  Id get id => startTime.microsecondsSinceEpoch;

  late DateTime startTime;

  /// The time zone offset from UTC at the start of activity, in minutes.
  /// Should be between -12 hours (Baker Island) and +14 hours (Kiribati).
  late int startTimeZoneOffsetMinutes;

  /// The name of the timezone at the start of the activity, as returned from
  /// [startTime.timeZoneName]
  String? startTimeZoneName;

  DateTime? stopTime;

  /// The sport practiced during activity, stored as a string.
  @Enumerated(EnumType.name)
  Sport? sport;

  String? name;

  double? distanceInMeters;

  late int durationInMicroSeconds;

  double? maxSpeedInMetersPerSecond;

  double? averageSpeedInMetersPerSecond;

  double? averageHeartBeatPerMinute;

  String? notes;

  List<TrackSegmentModel> trackSegments = [];
}

@embedded
class TrackSegmentModel {
  List<TrackPointModel> trackPoints = [];
}

@embedded
class TrackPointModel {
  LocationModel? location;
  late DateTime timestamp;
  double? heartBeatPerMinute;
}

@embedded
class LocationModel {
  late GpsCoordinatesModel gpsCoordinates;
  late double altitudeInMeters;
  late double errorInMeters;
  late double headingInDegrees;
  late double speedInMetersPerSecond;
  late double speedErrorInMetersPerSecond;
}

@embedded
class GpsCoordinatesModel {
  late double latitudeInDegrees;
  late double longitudeInDegrees;
}
