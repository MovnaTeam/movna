import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_type/result_type.dart';

/// Returns the device current [Location] or a [Fault] if the location could
/// not be retrieved.
///
/// See [LocationRepository.getLocation] for more details.
@injectable
class GetLocation implements UseCaseAsync<Location, void> {
  GetLocation({required this.repository});

  final LocationRepository repository;

  @override
  Future<Result<Location, Fault>> call([void p]) {
    return repository.getLocation();
  }
}
