import 'package:movna/domain/faults.dart';
import 'package:result_type/result_type.dart';

/// Interface that defines the behavior of a synchronous use-case.
///
/// Such a use-case returns either a [Fault] or the desired object
///
/// [R] is the return type of the use-case.
/// [P] is the type of the use-case's arguments.
abstract interface class UseCaseSync<R, P> {
  Result<R, Fault> call(P params);
}

/// Interface that defines the behavior of an asynchronous use-case.
///
/// Such a use-case returns a [Future] of either a [Fault] or the desired
/// object
///
/// [R] is the return type of the use-case.
/// [P] is the type of the use-case's arguments.
abstract interface class UseCaseAsync<R, P> {
  Future<Result<R, Fault>> call(P params);
}

/// Interface that defines the behavior of an asynchronous stream use-case.
///
/// Such a use-case returns a [Stream] of either a [Fault] or the desired
/// object
///
/// [R] is the return type of the use-case.
/// [P] is the type of the use-case's arguments.
abstract interface class UseCaseStream<R, P> {
  Stream<Result<R, Fault>> call(P params);
}
