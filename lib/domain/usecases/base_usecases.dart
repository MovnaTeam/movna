import 'package:dartz/dartz.dart';
import 'package:movna/domain/failures.dart';

/// Interface that defines the behavior of a synchronous use-case.
///
/// Such a use-case returns either a [Failure] or the desired object
///
/// [R] is the return type of the use-case.
/// [P] is the type of the use-case's arguments.
abstract interface class UseCaseSync<R, P> {
  Either<Failure, R> call(P params);
}

/// Interface that defines the behavior of an asynchronous use-case.
///
/// Such a use-case returns a [Future] of either a [Failure] or the desired
/// object
///
/// [R] is the return type of the use-case.
/// [P] is the type of the use-case's arguments.
abstract interface class UseCaseAsync<R, P> {
  Future<Either<Failure, R>> call(P params);
}

/// Interface that defines the behavior of an asynchronous stream use-case.
///
/// Such a use-case returns a [Stream] of either a [Failure] or the desired
/// object
///
/// [R] is the return type of the use-case.
/// [P] is the type of the use-case's arguments.
abstract interface class UseCaseStream<R, P> {
  Stream<Either<Failure, R>> call(P params);
}
