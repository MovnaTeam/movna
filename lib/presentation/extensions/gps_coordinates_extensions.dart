import 'package:latlong2/latlong.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';

extension GpsCoordinatesExt on GpsCoordinates {
  LatLng toLatLng() => LatLng(latitudeInDegrees, longitudeInDegrees);
}