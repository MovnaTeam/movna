import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/usecases/get_location_service_status.dart';
import 'package:movna/domain/usecases/request_location_service.dart';
import 'package:movna/domain/usecases/watch_location_service_status.dart';
import 'package:result_dart/result_dart.dart';

part 'location_service_cubit.freezed.dart';

/// Cubit responsible for interacting with the location service.
///
/// Upon initialization starts to listen to the service status and emits when
/// the status changes.
///
/// Call [requestLocationService] to try to enable the service.
@injectable
class LocationServiceCubit extends Cubit<LocationServiceState> {
  LocationServiceCubit(
    this._getLocationServiceStatus,
    this._requestLocationService,
    this._watchLocationServiceStatus,
  ) : super(const LocationServiceState.initial()) {
    _initCubit();
  }

  final GetLocationServiceStatus _getLocationServiceStatus;
  final RequestLocationService _requestLocationService;
  final WatchLocationServiceStatus _watchLocationServiceStatus;

  late final StreamSubscription<Result<LocationServiceStatus, Fault>>
      _locationServiceStatusSubscription;

  void _initCubit() async {
    emit(const LocationServiceState.loading());
    final serviceResult = await _getLocationServiceStatus();
    serviceResult.fold(
      (success) {
        emit(LocationServiceState.loaded(status: success));
      },
      (failure) {
        emit(LocationServiceState.error(fault: failure));
      },
    );
    _initLocationServiceWatch();
  }

  void _initLocationServiceWatch() {
    _locationServiceStatusSubscription = _watchLocationServiceStatus().listen(
      (statusResult) {
        statusResult.fold(
          (success) {
            emit(LocationServiceState.loaded(status: success));
          },
          (failure) {
            emit(LocationServiceState.error(fault: failure));
          },
        );
      },
    );
  }

  /// Tries to enable the location service.
  void requestLocationService() async {
    await _requestLocationService();
  }

  @override
  Future<void> close() async {
    await _locationServiceStatusSubscription.cancel();
    return super.close();
  }
}

@freezed
class LocationServiceState with _$LocationServiceState {
  const factory LocationServiceState.loaded({
    required LocationServiceStatus status,
  }) = _Loaded;

  const factory LocationServiceState.loading() = _Loading;

  const factory LocationServiceState.initial() = _Initial;

  const factory LocationServiceState.error({required Fault fault}) = _Error;
}
