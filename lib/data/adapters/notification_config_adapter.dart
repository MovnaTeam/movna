import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/data/adapters/base_adapter.dart';
import 'package:movna/domain/entities/notification_config.dart';

@injectable
class NotificationConfigAdapter
    extends BaseAdapter<NotificationConfig?, ForegroundNotificationConfig?> {
  @override
  ForegroundNotificationConfig? entityToModel(NotificationConfig? e) {
    if (e == null) return null;
    return ForegroundNotificationConfig(
      notificationTitle: e.title,
      notificationText: e.text,
      notificationIcon: const AndroidResource(name: 'ic_notification'),
      setOngoing: true,
    );
  }
}
