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
      expect(distance, closeTo(10001965.72931165, 10));
    },
  );
}
