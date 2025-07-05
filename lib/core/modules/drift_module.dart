import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:movna/data/datasources/drift_database.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const baseDrift = Named('movna_database');
const baseDriftDirectory = Named('driftDirectory');

@module
abstract class DriftModule {
  /// Factory method that creates an [Drift] instance from the [driftDirectory]
  @baseDrift
  AppDriftDatabase getBaseDriftInstance(
    @baseDriftDirectory Directory driftDirectory,
  ) {
    return AppDriftDatabase(baseDrift.name!, driftDirectory);
  }

  /// Pre resolved factory that returns the directory for the [Drift] database.
  @baseDriftDirectory
  @preResolve
  Future<Directory> get driftDirectory async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final dataBaseDirectory =
        Directory(path.join(appDirectory.path, 'database'));
    await dataBaseDirectory.create();
    return dataBaseDirectory;
  }
}
