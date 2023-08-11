import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Datasource that interfaces with a location provider to retrieve the device's
/// location (or position)
abstract class PositionSource {
  /// Returns the current device location.
  Future<Position> getPosition();

  /// Emits the device location in a stream until cancelled.
  ///
  /// Provide [notificationConfig] to specify the title and text of the
  /// notification allowing for background location access.
  Stream<Position> getPositionStream(
    ForegroundNotificationConfig notificationConfig,
  );

  Future<bool> isLocationServiceEnabled();

  Future<void> requestLocationService();
}

@Injectable(as: PositionSource)
class PositionSourceImpl extends PositionSource {
  static const _channel = MethodChannel('dev.movna.app/location');
  static const _enableLocationServiceMethod = 'enable_service';
  static const _positionRefreshInterval = Duration(seconds: 1);

  @override
  Future<Position> getPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  @override
  Stream<Position> getPositionStream(
    ForegroundNotificationConfig notificationConfig,
  ) {
    return Geolocator.getPositionStream(
      locationSettings: Platform.isAndroid
          ? AndroidSettings(
              // Set to best available accuracy.
              accuracy: LocationAccuracy.best,
              intervalDuration: _positionRefreshInterval,
              foregroundNotificationConfig: notificationConfig,
            )
          : const LocationSettings(
              accuracy: LocationAccuracy.best,
            ),
    );
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<void> requestLocationService() async {
    await _channel.invokeMethod(_enableLocationServiceMethod);
  }
}
