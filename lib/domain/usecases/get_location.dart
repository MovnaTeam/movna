import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

/// Returns the device current [Location] or a [Failure] if the location could
/// not be retrieved.
///
/// See [LocationRepository.getLocation] for more details.
@injectable
class GetLocation implements UseCaseAsync<Location, void> {
  GetLocation({required this.repository});

  final LocationRepository repository;

  @override
  Future<Either<Failure, Location>> call([void p]) {
    return repository.getLocation();
  }
}
