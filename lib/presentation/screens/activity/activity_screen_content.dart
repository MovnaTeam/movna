import 'package:flutter/material.dart';
import 'package:movna/presentation/screens/activity/views/map/activity_map_view.dart';
import 'package:movna/presentation/screens/activity/views/notifications/activity_notifications.dart';

/// Displays the content of the activity screen.
///
/// Displays the [ActivityMapView] overlayed by eventual
/// [ActivityNotifications].
class ActivityScreenContent extends StatelessWidget {
  const ActivityScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        ActivityMapView(),
        ActivityNotifications(),
      ],
    );
  }
}
