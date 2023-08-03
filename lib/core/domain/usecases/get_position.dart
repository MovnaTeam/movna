import 'package:injectable/injectable.dart';
import 'package:movna/core/domain/entities/position.dart';
import 'package:movna/core/domain/repositories/position_repository.dart';

@Injectable()
class GetPosition {
  GetPosition({required this.repository});
  final PositionRepository repository;

  Future<Position> call() {
    return repository.getPosition();
  }
}
