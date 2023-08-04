import 'package:flutter_test/flutter_test.dart';
import 'package:movna/domain/entities/location.dart';

void main() {
  test(
    'Distance between positions',
    () {
      Location p1 =
          const Location(latitudeInDegrees: 0.0, longitudeInDegrees: 0.0);
      Location p2 =
          const Location(latitudeInDegrees: 90.0, longitudeInDegrees: 0.0);
      double distance = p1.distanceToInMeters(p2);
      // With 10m of uncertainty
      expect(distance, closeTo(10001965.72931165, 10));
    },
  );
}
