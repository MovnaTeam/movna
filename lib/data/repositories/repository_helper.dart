import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/data/adapters/base_adapter.dart';
import 'package:movna/domain/failures.dart';

/// A mixin containing helper methods for repositories
mixin RepositoryHelper {
  /// Converts a [modelStream] to a stream of [Either<Failure, Entity>].
  ///
  /// Takes an [adapter] to convert the incoming models to entities.
  /// [errorHandler] is a function that converts an error to a [Failure] that
  /// will be emitted if the [modelStream] emits an error.
  /// When such an error is emitted by [modelStream] this method will log the
  /// error and stackTrace along with the [errorLoggerMessage].
  Stream<Either<Failure, Entity>> convertStream<Entity, Model>({
    required Stream<Model> modelStream,
    required BaseAdapter<Entity, Model> adapter,
    required Failure Function(Object) errorHandler,
    required String errorLoggerMessage,
  }) {
    return modelStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (Model data, sink) {
          try {
            final entity = adapter.modelToEntity(data);
            sink.add(Right(entity));
          } catch (e, s) {
            logger.e(
              'Error converting $Model to $Entity',
              error: e,
              stackTrace: s,
            );
            sink.add(
              const Left(
                Failure.adapter(),
              ),
            );
          }
        },
        handleError: (error, stack, sink) {
          logger.e(
            errorLoggerMessage,
            error: error,
            stackTrace: stack,
          );
          final failure = errorHandler(error);
          sink.add(Left(failure));
        },
      ),
    );
  }
}
