import 'package:flutter_test/flutter_test.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';

void main() {
  test(
    'Distance between positions',
    () {
      GpsCoordinates p1 = const GpsCoordinates(0.0, 0.0);
      GpsCoordinates p2 = const GpsCoordinates(90.0, 0.0);
      double distance = p1.distanceToInMeters(p2);
      // With 10m of uncertainty
      // Expected value computed here :
      // https://gps-coordinates.org/distance-between-coordinates.php
      expect(distance, closeTo(10007543.40, 10));
    },
  );
}
