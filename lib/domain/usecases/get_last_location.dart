import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/timed_location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// A usecase that returns the last known location of the device.
@injectable
class GetLastKnownLocation implements UseCaseAsync<TimedLocation, void> {
  GetLastKnownLocation({required this.repository});

  final TimedLocationRepository repository;

  @override
  Future<ResultDart<TimedLocation, Fault>> call([void params]) async {
    return repository.getLastKnownLocation();
  }
}
