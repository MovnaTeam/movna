import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/position.dart';
import 'package:movna/domain/repositories/position_repository.dart';

@Injectable()
class GetPosition {
  GetPosition({required this.repository});

  final PositionRepository repository;

  Future<Position> call() {
    return repository.getPosition();
  }
}
