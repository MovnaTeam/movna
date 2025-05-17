import 'dart:async';

import 'package:movna/core/logger.dart';
import 'package:movna/data/adapters/base_adapter.dart';
import 'package:movna/domain/faults.dart';
import 'package:result_dart/result_dart.dart';

/// A mixin containing helper methods for repositories
mixin RepositoryHelper {
  /// Converts a [modelStream] to a stream of [ResultDart<Entity, Fault>].
  ///
  /// Takes an [adapter] to convert the incoming models to entities.
  /// [errorHandler] is a function that converts an error to a [Fault] that
  /// will be emitted if the [modelStream] emits an error.
  /// When such an error is emitted by [modelStream] this method will log the
  /// error and stackTrace along with the [errorLoggerMessage].
  Stream<ResultDart<Entity, Fault>>
      convertStream<Entity extends Object, Model>({
    required Stream<Model> modelStream,
    required BaseAdapter<Entity, Model> adapter,
    required Fault Function(Object) errorHandler,
    required String errorLoggerMessage,
  }) {
    return modelStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (Model data, sink) {
          try {
            final entity = adapter.convertModel(data);
            sink.add(entity.toSuccess());
          } catch (e, s) {
            logger.e(
              'Error converting $Model to $Entity',
              error: e,
              stackTrace: s,
            );
            sink.add(const Fault.entityNotSourced().toFailure());
          }
        },
        handleError: (error, stack, sink) {
          logger.e(
            errorLoggerMessage,
            error: error,
            stackTrace: stack,
          );
          final failure = errorHandler(error);
          sink.add(failure.toFailure());
        },
      ),
    );
  }
}
