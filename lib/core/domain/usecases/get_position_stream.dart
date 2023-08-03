import 'package:injectable/injectable.dart';
import 'package:movna/core/domain/entities/position.dart';
import 'package:movna/core/domain/repositories/position_repository.dart';

@Injectable()
class GetPositionStream {
  GetPositionStream({required this.repository});
  final PositionRepository repository;

  Future<Stream<Position>> call() {
    return repository.getPositionStream();
  }
}
