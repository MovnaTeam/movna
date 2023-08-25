import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/data/adapters/base_adapter.dart';
import 'package:movna/domain/entities/location_service_status.dart';

@injectable
class LocationServiceStatusAdapter
    extends BaseAdapter<LocationServiceStatus, ServiceStatus> {
  @override
  LocationServiceStatus modelToEntity(ServiceStatus m) {
    return switch (m) {
      ServiceStatus.enabled => LocationServiceStatus.enabled,
      ServiceStatus.disabled => LocationServiceStatus.disabled,
    };
  }
}
