import 'package:injectable/injectable.dart';
import 'package:movna/data/adapters/base_adapter.dart';
import 'package:movna/data/datasources/drift_database.dart';
import 'package:movna/data/models/activity_drift_model.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/domain/entities/track_point.dart';
import 'package:movna/domain/entities/track_segment.dart';
import 'package:uuid/uuid.dart';

@injectable
class ActivityDriftAdapter extends BaseAdapter<Activity, ActivityDriftModel> {
  ActivityDriftAdapter(this.trackSegmentDriftAdapter);

  TrackSegmentDriftAdapter trackSegmentDriftAdapter;

  @override
  Activity modelToEntity(ActivityDriftModel m) {
    return Activity(
      id: m.id,
      name: m.name,
      sport: m.sport,
      startTime: m.startTime,
      stopTime: m.stopTime,
      distanceInMeters: m.distanceInMeters,
      duration: Duration(microseconds: m.durationInMicroSeconds),
      averageSpeedInMetersPerSecond: m.averageSpeedInMetersPerSecond,
      maxSpeedInMetersPerSecond: m.maxSpeedInMetersPerSecond,
      averageHeartBeatPerMinute: m.averageHeartBeatPerMinute,
      notes: m.notes,
      trackSegments: trackSegmentDriftAdapter.modelsToEntities(m.trackSegments),
    );
  }

  @override
  ActivityDriftModel entityToModel(Activity e) => ActivityDriftModel(
        // TODO fix this nullable mess
        id: e.id.isEmpty ? Uuid().v7() : e.id,
        name: e.name ?? '',
        sport: e.sport ?? Sport.other,
        startTime: e.startTime,
        stopTime: e.stopTime,
        distanceInMeters: e.distanceInMeters ?? 0,
        durationInMicroSeconds: e.duration.inMicroseconds,
        averageSpeedInMetersPerSecond: e.averageSpeedInMetersPerSecond ?? 0,
        maxSpeedInMetersPerSecond: e.maxSpeedInMetersPerSecond ?? 0,
        averageHeartBeatPerMinute: e.averageHeartBeatPerMinute,
        notes: e.notes ?? '',
        trackSegments: trackSegmentDriftAdapter.entitiesToModels(
          e.trackSegments,
        ),
      );
}

@injectable
class TrackSegmentDriftAdapter
    extends BaseAdapter<TrackSegment, TrackSegmentDriftModel> {
  TrackSegmentDriftAdapter(this.trackPointDriftAdapter);

  TrackPointDriftAdapter trackPointDriftAdapter;

  @override
  TrackSegment modelToEntity(TrackSegmentDriftModel m) {
    return TrackSegment(
      trackPoints: trackPointDriftAdapter.modelsToEntities(m.trackPoints),
    );
  }

  @override
  TrackSegmentDriftModel entityToModel(TrackSegment e) =>
      TrackSegmentDriftModel(
        trackPoints: trackPointDriftAdapter.entitiesToModels(e.trackPoints),
      );
}

@injectable
class TrackPointDriftAdapter
    extends BaseAdapter<TrackPoint, TrackPointDriftModel> {
  TrackPointDriftAdapter(this.locationDriftAdapter);

  LocationDriftAdapter locationDriftAdapter;

  @override
  TrackPoint modelToEntity(TrackPointDriftModel m) => TrackPoint(
        location: m.location == null
            ? null
            : locationDriftAdapter.modelToEntity(m.location!),
        timestamp: m.timestamp,
        heartBeatPerMinute: m.heartBeatPerMinute,
      );

  @override
  TrackPointDriftModel entityToModel(TrackPoint e) => TrackPointDriftModel(
        location: (e.location == null
            ? null
            : locationDriftAdapter.entityToModel(e.location!)),
        timestamp: e.timestamp,
        heartBeatPerMinute: e.heartBeatPerMinute,
      );
}

@injectable
class LocationDriftAdapter extends BaseAdapter<Location, LocationDriftModel> {
  LocationDriftAdapter(this.gpsCoordinatesDriftAdapter);

  GpsCoordinatesDriftAdapter gpsCoordinatesDriftAdapter;

  @override
  Location modelToEntity(LocationDriftModel m) {
    return Location(
      gpsCoordinates:
          gpsCoordinatesDriftAdapter.modelToEntity(m.gpsCoordinates),
      altitudeInMeters: m.altitudeInMeters,
      errorInMeters: m.errorInMeters,
      headingInDegrees: m.headingInDegrees,
      speedInMetersPerSecond: m.speedInMetersPerSecond,
      speedErrorInMetersPerSecond: m.speedErrorInMetersPerSecond,
    );
  }

  @override
  LocationDriftModel entityToModel(Location e) => LocationDriftModel(
        gpsCoordinates:
            gpsCoordinatesDriftAdapter.entityToModel(e.gpsCoordinates),
        altitudeInMeters: e.altitudeInMeters,
        errorInMeters: e.errorInMeters,
        headingInDegrees: e.headingInDegrees,
        speedErrorInMetersPerSecond: e.speedErrorInMetersPerSecond,
        speedInMetersPerSecond: e.speedInMetersPerSecond,
      );
}

@injectable
class GpsCoordinatesDriftAdapter
    extends BaseAdapter<GpsCoordinates, GpsCoordinatesDriftModel> {
  @override
  GpsCoordinates modelToEntity(GpsCoordinatesDriftModel m) =>
      GpsCoordinates(m.latitudeInDegrees, m.longitudeInDegrees);

  @override
  GpsCoordinatesDriftModel entityToModel(GpsCoordinates e) =>
      GpsCoordinatesDriftModel(
        latitudeInDegrees: e.latitudeInDegrees,
        longitudeInDegrees: e.longitudeInDegrees,
      );
}
