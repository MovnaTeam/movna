import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:movna/data/models/activity_model.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const baseIsar = Named('baseIsar');
const baseIsarDirectory = Named('isarDirectory');

@module
abstract class IsarModule {
  /// Factory method that creates an [Isar] instance from the [isarDirectory]
  @baseIsar
  Isar getBaseIsarInstance(@baseIsarDirectory Directory isarDirectory) {
    final isar = Isar.getInstance(baseIsar.name!);
    if (isar != null) {
      return isar;
    }

    final newIsarInstance = Isar.openSync(
      [ActivityModelSchema],
      directory: isarDirectory.path,
      name: baseIsar.name!,
    );

    return newIsarInstance;
  }

  /// Pre resolved factory that returns the directory for the [Isar] database.
  @baseIsarDirectory
  @preResolve
  Future<Directory> get isarDirectory async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final isarDirectory = Directory(path.join(appDirectory.path, 'isar'));
    await isarDirectory.create();
    return isarDirectory;
  }
}
