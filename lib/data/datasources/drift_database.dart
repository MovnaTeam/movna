import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:movna/data/models/activity_drift_model.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:uuid/uuid.dart';

part 'drift_database.g.dart';

@DriftDatabase(tables: [ActivityDriftModels])
class AppDriftDatabase extends _$AppDriftDatabase {
  AppDriftDatabase(String name, Directory directory)
      : super(_openConnection(name, directory));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(String name, Directory directory) {
    return driftDatabase(
      name: name,
      native: DriftNativeOptions(
        databaseDirectory: () async => directory,
      ),
    );
  }
}