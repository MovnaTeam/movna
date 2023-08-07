import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:movna/core/injection.config.dart';
import 'package:movna/data/models/activity_model.dart';
import 'package:movna/domain/failures.dart';
import 'package:path_provider/path_provider.dart';

final injector = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  injector.init();
  injector.registerLazySingletonAsync<Either<Failure, Isar>>(
    () async => await _openIsar(),
    dispose: (isar) => _closeIsar(isar),
  );
}

Future<Either<Failure, void>> _closeIsar(Either<Failure, Isar> isar) async {
  if (isar.isRight()) {
    if (!await (isar as Isar).close()) {
      return const Left(Failure.database());
    } else {
      return const Right(null);
    }
  } else {
    return const Left(Failure.databaseNotClosed());
  }
}

Future<Either<Failure, Isar>> _openIsar() async {
  late Directory directory;

  try {
    directory = await getApplicationDocumentsDirectory();
  } on MissingPlatformDirectoryException {
    return const Left(Failure.documentDirectoryUnavailable());
  } catch (e) {
    return const Left(Failure.unknown());
  }
  late Isar isar;
  try {
    isar = await Isar.open(
      [ActivityModelSchema],
      directory: directory.path,
    );
  } catch (e) {
    return const Left(Failure.databaseNotOpened());
  }

  return Right(isar);
}
