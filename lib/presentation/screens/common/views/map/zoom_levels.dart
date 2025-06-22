/// Representation of the zoom levels used by OpenStreetMap.
/// More info at https://wiki.openstreetmap.org/wiki/Zoom_levels.
sealed class ZoomLevel {
  static const double wholeWorld = 0;
  static const double subcontinentalArea = 2;
  static const double largestCountry = 3;
  static const double largeAfricanCountry = 5;
  static const double largeEuropeanCountry = 6;
  static const double smallCountry = 7;
  static const double wideMetropolitanArea = 9;
  static const double metropolitanArea = 10;
  static const double city = 11;
  static const double cityDistrict = 12;
  static const double village = 13;
  static const double smallRoad = 15;
  static const double street = 16;
  static const double block = 17;
  static const double buildings = 18;
  static const double crossingDetails = 19;
  static const double midSizedBuilding = 20;

  static const double min = wholeWorld;
  // Open street map does not provide tiles above this zoom level.
  static const double max = crossingDetails;
}
