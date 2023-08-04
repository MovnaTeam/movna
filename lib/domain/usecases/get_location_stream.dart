import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

/// Returns a stream of device current [Location] or a [Failure] if an error
/// occurs while the stream is active.
///
/// See [LocationRepository.getLocationStream] for more details.
@injectable
class GetLocationStream implements UseCaseStream<Location, void> {
  GetLocationStream({required this.repository});

  final LocationRepository repository;

  @override
  Stream<Either<Failure, Location>> call([void p]) {
    return repository.getLocationStream();
  }
}
