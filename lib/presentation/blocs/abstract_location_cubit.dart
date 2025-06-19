import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/faults.dart';

/// Abstract class representing a cubit that can keep track of the device
/// location.
///
/// Implementing cubits' states must implement [AbstractLocationState].
abstract class AbstractLocationCubit<T extends AbstractLocationState>
    extends Cubit<T> {
  AbstractLocationCubit(super.initialState);
}

abstract interface class AbstractLocationState {
  Location? get location;

  LocationStateType get type;

  Fault? get fault;
}

enum LocationStateType { initial, loading, error, loaded, done }
