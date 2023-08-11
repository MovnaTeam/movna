import 'package:injectable/injectable.dart';
import 'package:movna/data/adapters/base_adapter.dart';
import 'package:movna/data/models/activity_model.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/entities/track_point.dart';
import 'package:movna/domain/entities/track_segment.dart';

@injectable
class ActivityIsarAdapter extends BaseAdapter<Activity, ActivityModel> {
  ActivityIsarAdapter(this.trackSegmentIsarAdapter);

  TrackSegmentIsarAdapter trackSegmentIsarAdapter;

  @override
  Activity modelToEntity(ActivityModel m) {
    return Activity(
      name: m.name,
      sport: m.sport,
      startTime: m.startTime,
      // TODO : handle timezone using startTimeZoneOffsetMinutes and Name
      stopTime: m.stopTime,
      distanceInMeters: m.distanceInMeters,
      duration: m.durationInMicroSeconds != null
          ? Duration(microseconds: m.durationInMicroSeconds!)
          : null,
      averageSpeedInMetersPerSecond: m.averageSpeedInMetersPerSecond,
      maxSpeedInMetersPerSecond: m.maxSpeedInMetersPerSecond,
      averageHeartBeatPerMinute: m.averageHeartBeatPerMinute,
      notes: m.notes,
      trackSegments: trackSegmentIsarAdapter.modelsToEntities(m.trackSegments),
    );
  }

  @override
  ActivityModel entityToModel(Activity e) {
    final m = ActivityModel()
      ..name = e.name
      ..sport = e.sport
      ..startTime = e.startTime.toUtc() // UTC conversion is done by isar anyway
      ..startTimeZoneName = e.startTime.timeZoneName
      ..startTimeZoneOffsetMinutes = e.startTime.timeZoneOffset.inMinutes
      ..stopTime = e.stopTime?.toUtc() // UTC conversion is done by isar anyway
      ..distanceInMeters = e.distanceInMeters
      ..durationInMicroSeconds = e.duration?.inMicroseconds
      ..averageSpeedInMetersPerSecond = e.averageSpeedInMetersPerSecond
      ..maxSpeedInMetersPerSecond = e.maxSpeedInMetersPerSecond
      ..averageHeartBeatPerMinute = e.averageHeartBeatPerMinute
      ..notes = e.notes
      ..trackSegments =
          trackSegmentIsarAdapter.entitiesToModels(e.trackSegments);
    return m;
  }
}

@injectable
class TrackSegmentIsarAdapter
    extends BaseAdapter<TrackSegment, TrackSegmentModel> {
  TrackSegmentIsarAdapter(this.trackPointIsarAdapter);

  TrackPointIsarAdapter trackPointIsarAdapter;

  @override
  TrackSegment modelToEntity(TrackSegmentModel m) {
    return TrackSegment(
      trackPoints: trackPointIsarAdapter.modelsToEntities(m.trackPoints),
    );
  }

  @override
  TrackSegmentModel entityToModel(TrackSegment e) {
    final m = TrackSegmentModel()
      ..trackPoints = trackPointIsarAdapter.entitiesToModels(e.trackPoints);
    return m;
  }
}

@injectable
class TrackPointIsarAdapter extends BaseAdapter<TrackPoint, TrackPointModel> {
  TrackPointIsarAdapter(this.locationIsarAdapter);

  LocationIsarAdapter locationIsarAdapter;

  @override
  TrackPoint modelToEntity(TrackPointModel m) {
    return TrackPoint(
      location: m.location == null
          ? null
          : locationIsarAdapter.modelToEntity(m.location!),
      heartBeatPerMinute: m.heartBeatPerMinute,
    );
  }

  @override
  TrackPointModel entityToModel(TrackPoint e) {
    final m = TrackPointModel()
      ..location = (e.location == null
          ? null
          : locationIsarAdapter.entityToModel(e.location!))
      ..heartBeatPerMinute = e.heartBeatPerMinute;
    return m;
  }
}

@injectable
class LocationIsarAdapter extends BaseAdapter<Location, LocationModel> {
  LocationIsarAdapter(this.gpsCoordinatesIsarAdapter);

  GpsCoordinatesIsarAdapter gpsCoordinatesIsarAdapter;

  @override
  Location modelToEntity(LocationModel m) {
    return Location(
      gpsCoordinates: gpsCoordinatesIsarAdapter.modelToEntity(m.gpsCoordinates),
      altitudeInMeters: m.altitudeInMeters,
      errorInMeters: m.errorInMeters,
      headingInDegrees: m.headingInDegrees,
      speedInMetersPerSecond: m.speedInMetersPerSecond,
      speedErrorInMetersPerSecond: m.speedErrorInMetersPerSecond,
      timestamp: m.timestamp,
    );
  }

  @override
  LocationModel entityToModel(Location e) {
    final m = LocationModel()
      ..gpsCoordinates =
          gpsCoordinatesIsarAdapter.entityToModel(e.gpsCoordinates)
      ..altitudeInMeters = e.altitudeInMeters
      ..errorInMeters = e.errorInMeters
      ..headingInDegrees = e.headingInDegrees
      ..speedErrorInMetersPerSecond = e.speedErrorInMetersPerSecond
      ..speedInMetersPerSecond = e.speedInMetersPerSecond
      ..timestamp = e.timestamp;
    return m;
  }
}

@injectable
class GpsCoordinatesIsarAdapter
    extends BaseAdapter<GpsCoordinates, GpsCoordinatesModel> {
  @override
  GpsCoordinates modelToEntity(GpsCoordinatesModel m) {
    return GpsCoordinates(m.latitudeInDegrees, m.longitudeInDegrees);
  }

  @override
  GpsCoordinatesModel entityToModel(GpsCoordinates e) {
    final m = GpsCoordinatesModel()
      ..latitudeInDegrees = e.latitudeInDegrees
      ..longitudeInDegrees = e.longitudeInDegrees;
    return m;
  }
}
