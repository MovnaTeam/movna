import 'package:isar/isar.dart';
import 'package:movna/domain/entities/sport.dart';

part 'activity_model.g.dart';

@Collection()
class ActivityModel {
  /// Use startTime as unique identifier.
  Id get id => startTime.microsecondsSinceEpoch;

  DateTime startTime = DateTime.fromMillisecondsSinceEpoch(0);

  DateTime? stopTime;

  // TODO : add field timezoneOffset or timezone to store localTime as well,
  // In order to be able to restore the original date times, which were
  // converted to UTC when stored in database.

  @Enumerated(EnumType.name)
  Sport? sport;

  String? name;

  double distanceInMeters = 0;

  int durationInMicroSeconds = 0;

  double maxSpeedInMetersPerSecond = 0;

  double averageSpeedInMetersPerSecond = 0;

  double? averageHeartBeatPerMinute;

  String notes = '';

  List<TrackSegmentModel> trackSegments = [];
}

@embedded
class TrackSegmentModel {
  List<TrackPointModel> trackPoints = [];
}

@embedded
class TrackPointModel {
  LocationModel? location;
  double? heartBeatPerMinute;
}

@embedded
class LocationModel {
  GpsCoordinatesModel gpsCoordinates = GpsCoordinatesModel();
  double altitudeInMeters = 0;
  double errorInMeters = 0;
  double headingInDegrees = 0;
  double speedInMetersPerSecond = 0;
  double speedErrorInMetersPerSecond = 0;
  DateTime? timestamp;
}

@embedded
class GpsCoordinatesModel {
  double latitudeInDegrees = 0;
  double longitudeInDegrees = 0;
}
