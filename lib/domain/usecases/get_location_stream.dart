import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Returns a stream of device current [Location] or a [Fault] if an error
/// occurs while the stream is active.
///
/// See [LocationRepository.getLocationStream] for more details.
@injectable
class GetLocationStream implements UseCaseStream<Location, void> {
  GetLocationStream({required this.repository});

  final LocationRepository repository;

  @override
  Stream<Result<Location, Fault>> call([void p]) {
    return repository.getLocationStream();
  }
}
