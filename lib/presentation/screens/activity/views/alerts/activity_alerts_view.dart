import 'package:flutter/material.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/activity/views/alerts/activity_location_service_alert.dart';
import 'package:movna/presentation/screens/activity/views/alerts/activity_permission_alert.dart';

/// This widget shows a variety of alert cards depending on the
/// app's status.
///
/// See also:
///   * [ActivityPermissionAlertWidget] The widget displaying app
///   permission related information to the user along with a callback to grant
///   missing permissions.
class ActivityAlertsView extends StatelessWidget {
  const ActivityAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ActivityLocationServiceAlert(),
        ActivityPermissionAlertWidget(
          title: LocaleKeys.permissions.notifications.alert
              .title()
              .translate(context),
          body: LocaleKeys.permissions.notifications.alert
              .body()
              .translate(context),
          permissionType: PermissionType.notifications,
        ),
        ActivityPermissionAlertWidget(
          title: LocaleKeys.permissions.location.alert
              .title()
              .translate(context),
          body: LocaleKeys.permissions.location.alert
              .body()
              .translate(context),
          permissionType: PermissionType.location,
        ),
      ],
    );
  }
}
