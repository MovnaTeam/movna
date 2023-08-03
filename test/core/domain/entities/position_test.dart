import 'package:flutter_test/flutter_test.dart';
import 'package:movna/core/domain/entities/position.dart';

void main() {
  test(
    'Distance between positions',
    () {
      Position p1 =
          const Position(latitudeInDegrees: 0.0, longitudeInDegrees: 0.0);
      Position p2 =
          const Position(latitudeInDegrees: 90.0, longitudeInDegrees: 0.0);
      double distance = p1.distanceToInMeters(p2);
      // With 10m of uncertainty
      expect(distance, closeTo(10001965.72931165, 10));
    },
  );
}
