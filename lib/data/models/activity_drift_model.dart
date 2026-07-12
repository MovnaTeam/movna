import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:uuid/uuid.dart';

part 'activity_drift_model.g.dart';

class ActivityDriftModels extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v7())();
  @override
  Set<Column> get primaryKey => {id};

  DateTimeColumn get startTime => dateTime()();

  DateTimeColumn get stopTime => dateTime().nullable()();

  /// The sport practiced during activity, stored as a string.
  TextColumn get sport => textEnum<Sport>()();

  TextColumn get name => text()();

  RealColumn get distanceInMeters => real()();

  IntColumn get durationInMicroSeconds => integer()();

  RealColumn get maxSpeedInMetersPerSecond => real()();

  RealColumn get averageSpeedInMetersPerSecond => real()();

  RealColumn get averageHeartBeatPerMinute => real().nullable()();

  TextColumn get notes => text()();

  TextColumn get trackSegments =>
      text().map(const TrackSegmentsDriftModelConverter())();
}

class TrackSegmentsDriftModelConverter
    extends TypeConverter<List<TrackSegmentDriftModel>, String> {
  const TrackSegmentsDriftModelConverter();

  @override
  List<TrackSegmentDriftModel> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List)
          .map(
            (item) =>
                TrackSegmentDriftModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

  @override
  String toSql(List<TrackSegmentDriftModel> value) =>
      jsonEncode(value.map((a) => a.toJson()).toList());
}

@JsonSerializable()
class TrackSegmentDriftModel {
  factory TrackSegmentDriftModel.fromJson(Map<String, dynamic> json) =>
      _$TrackSegmentDriftModelFromJson(json);

  TrackSegmentDriftModel({required this.trackPoints});

  List<TrackPointDriftModel> trackPoints;

  Map<String, dynamic> toJson() => _$TrackSegmentDriftModelToJson(this);
}

@JsonSerializable()
class TrackPointDriftModel {
  factory TrackPointDriftModel.fromJson(Map<String, dynamic> json) =>
      _$TrackPointDriftModelFromJson(json);

  TrackPointDriftModel({
    required this.timestamp,
    this.location,
    this.heartBeatPerMinute,
  });

  DateTime timestamp;
  LocationDriftModel? location;
  double? heartBeatPerMinute;

  Map<String, dynamic> toJson() => _$TrackPointDriftModelToJson(this);
}

@JsonSerializable()
class LocationDriftModel {
  factory LocationDriftModel.fromJson(Map<String, dynamic> json) =>
      _$LocationDriftModelFromJson(json);

  LocationDriftModel({
    required this.gpsCoordinates,
    required this.altitudeInMeters,
    required this.errorInMeters,
    required this.headingInDegrees,
    required this.speedInMetersPerSecond,
    required this.speedErrorInMetersPerSecond,
  });

  GpsCoordinatesDriftModel gpsCoordinates;
  double altitudeInMeters;
  double errorInMeters;
  double headingInDegrees;
  double speedInMetersPerSecond;
  double speedErrorInMetersPerSecond;

  Map<String, dynamic> toJson() => _$LocationDriftModelToJson(this);
}

@JsonSerializable()
class GpsCoordinatesDriftModel {
  factory GpsCoordinatesDriftModel.fromJson(Map<String, dynamic> json) =>
      _$GpsCoordinatesDriftModelFromJson(json);

  GpsCoordinatesDriftModel({
    required this.latitudeInDegrees,
    required this.longitudeInDegrees,
  });

  double latitudeInDegrees;
  double longitudeInDegrees;

  Map<String, dynamic> toJson() => _$GpsCoordinatesDriftModelToJson(this);
}
