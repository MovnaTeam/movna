import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/position.dart';
import 'package:movna/domain/repositories/position_repository.dart';

@Injectable()
class GetPositionStream {
  GetPositionStream({required this.repository});

  final PositionRepository repository;

  Stream<Position> call() {
    return repository.getPositionStream();
  }
}
