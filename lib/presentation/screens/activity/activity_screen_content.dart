import 'package:flutter/material.dart';
import 'package:movna/presentation/screens/activity/views/alerts/activity_alerts_view.dart';
import 'package:movna/presentation/screens/activity/views/map/activity_map_view.dart';

/// Displays the content of the activity screen.
///
/// Displays the [ActivityMapView] overlayed by eventual
/// [ActivityAlert].
class ActivityScreenContent extends StatelessWidget {
  const ActivityScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        ActivityMapView(),
        ActivityAlertsView(),
      ],
    );
  }
}
