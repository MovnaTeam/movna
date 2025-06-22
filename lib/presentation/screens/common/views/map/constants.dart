import 'package:flutter/material.dart';
import 'package:movna/presentation/screens/common/views/map/zoom_levels.dart';

abstract interface class MapConstants {
  static const Duration mapAnimationsDuration = Duration(milliseconds: 500);
  static const Curve mapAnimationsCurve = Curves.easeInOut;
  static const double maxZoom = ZoomLevel.max;
  static const double defaultZoom = ZoomLevel.block;
  static const double errorZoom = ZoomLevel.largeEuropeanCountry;
  static const String urlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}
