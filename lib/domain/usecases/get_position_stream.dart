import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

@injectable
class GetPositionStream implements UseCaseStream<Location, void> {
  GetPositionStream({required this.repository});

  final LocationRepository repository;

  @override
  Stream<Either<Failure, Location>> call([void p]) {
    return repository.getLocationStream();
  }
}
