/// A [Exception] related to data conversion, such as model to entity.
///
/// As this exception is intended to be used as a wrapper around raised
/// exceptions raised during conversion it takes in a [causedBy] object that
/// represents the underlying exception and a [causeStackTrace] the [StackTrace]
/// of the underlying exception.
class ConversionException<Destination, Source> implements Exception {
  ConversionException(this.causedBy, this.causeStackTrace);

  final Object causedBy;
  final StackTrace causeStackTrace;

  @override
  String toString() {
    return '''
Error converting $Source to $Destination
Caused by: ${causedBy.toString()}
Stack trace: ${causeStackTrace.toString()}''';
  }
}
