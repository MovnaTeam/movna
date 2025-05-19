import 'package:movna/domain/faults.dart';
import 'package:result_dart/result_dart.dart';

/// A repository used to retrieve information related to user data.
abstract interface class UserRepository {
  /// Stores the given [level].
  ///
  /// Returns [Unit] on success and a [Fault] on failure.
  Future<ResultDart<Unit, Fault>> setDefaultZoomLevel(double level);

  /// Retrieves the latest zoom level stored by [setDefaultZoomLevel].
  ///
  /// If no value has been previously set, returns a [Fault.notFound].
  ResultDart<double, Fault> getDefaultZoomLevel();
}
