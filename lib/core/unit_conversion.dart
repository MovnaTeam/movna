import 'dart:math';

const _kiloFactor = 1e3;
const _hectoFactor = 1e2;
const _decaFactor = 1e1;
const _deciFactor = 1e-1;
const _centiFactor = 1e-2;
const _milliFactor = 1e-3;
const _microFactor = 1e-6;
const _nanoFactor = 1e-9;
const _picoFactor = 1e-12;
const _femtoFactor = 1e-15;

const _metersPerSecondToKilometersPerHourRatio =
    Duration.secondsPerHour / _kiloFactor;

/// Converts [speed] in kilometers per hour to meters per second.
double metersPerSecondToKilometersPerHour(double speed) {
  return speed * _metersPerSecondToKilometersPerHourRatio;
}

/// Converts [speed] in meters per second to kilometers per hour.
double kilometersPerHourToMetersPerSecond(double speed) {
  return speed / _metersPerSecondToKilometersPerHourRatio;
}

const _degreesPerRadian = 180;
const _degreesToRadiansRatio = pi / _degreesPerRadian;

/// Converts [angle] in degrees to radians.
double degreesToRadians(double angle) {
  return angle * _degreesToRadiansRatio;
}

/// Converts [angle] in radians to degrees.
double radiansToDegrees(double angle) {
  return angle / _degreesToRadiansRatio;
}
