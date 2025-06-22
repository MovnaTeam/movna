/// Representation of the zoom levels used by OpenStreetMap.
/// More info at https://wiki.openstreetmap.org/wiki/Zoom_levels.
enum ZoomLevel {
  wholeWorld,
  subcontinentalArea,
  largestCountry,
  largeAfricanCountry,
  largeEuropeanCountry,
  smallCountry,
  wideMetropolitanArea,
  metropolitanArea,
  city,
  cityDistrict,
  village,
  smallRoad,
  street,
  block,
  buildings,
  crossingDetails,
  midSizedBuilding
}

extension ZoomLevelValues on ZoomLevel {
  double toValue() => switch (this) {
        ZoomLevel.wholeWorld => 0,
        ZoomLevel.subcontinentalArea => 2,
        ZoomLevel.largestCountry => 3,
        ZoomLevel.largeAfricanCountry => 5,
        ZoomLevel.largeEuropeanCountry => 6,
        ZoomLevel.smallCountry => 7,
        ZoomLevel.wideMetropolitanArea => 9,
        ZoomLevel.metropolitanArea => 10,
        ZoomLevel.city => 11,
        ZoomLevel.cityDistrict => 12,
        ZoomLevel.village => 13,
        ZoomLevel.smallRoad => 15,
        ZoomLevel.street => 16,
        ZoomLevel.block => 17,
        ZoomLevel.buildings => 18,
        ZoomLevel.crossingDetails => 19,
        ZoomLevel.midSizedBuilding => 20,
      };
}
