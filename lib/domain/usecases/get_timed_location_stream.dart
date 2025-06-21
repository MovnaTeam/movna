import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/entities/timed_location.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/timed_location_repository.dart';
import 'package:movna/domain/usecases/base_usecases.dart';
import 'package:result_dart/result_dart.dart';

/// Returns a stream of device current [TimedLocation] or a [Fault] if an error
/// occurs while the stream is active.
/// 
/// If a [NotificationConfig] is provided, the service will try to run in the
/// background.
///
/// See [LocationRepository.getTimedLocationStream] for more details.
@injectable
class GetLocationStream
    implements UseCaseStream<TimedLocation, NotificationConfig> {
  GetLocationStream({required this.repository});

  final TimedLocationRepository repository;

  @override
  Stream<ResultDart<TimedLocation, Fault>> call([NotificationConfig? config]) {
    return repository.getTimedLocationStream(config);
  }
}
