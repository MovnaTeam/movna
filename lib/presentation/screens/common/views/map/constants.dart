import 'package:flutter/material.dart';

abstract interface class MapConstants {
  static const Duration mapAnimationsDuration = Duration(milliseconds: 500);
  static const Curve mapAnimationsCurve = Curves.easeInOut;
  static const double maxZoom = 18.49;
  static const String urlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}
