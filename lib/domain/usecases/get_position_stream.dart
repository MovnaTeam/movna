import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/position.dart';
import 'package:movna/domain/failures.dart';
import 'package:movna/domain/repositories/position_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';

@injectable
class GetPositionStream implements UseCaseStream<Position, void> {
  GetPositionStream({required this.repository});

  final PositionRepository repository;

  @override
  Stream<Either<Failure, Position>> call([void p]) {
    return repository.getPositionStream();
  }
}
