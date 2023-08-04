import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

@injectable
class GetPosition implements UseCaseAsync<Location, void> {
  GetPosition({required this.repository});

  final LocationRepository repository;

  @override
  Future<Either<Failure, Location>> call([void p]) {
    return repository.getLocation();
  }
}
