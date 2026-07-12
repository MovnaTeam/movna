import 'package:flutter/material.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/views/alerts/location_service_alert.dart';
import 'package:movna/presentation/screens/common/views/alerts/permission_alert.dart';

/// This widget shows a variety of alert cards depending on the
/// app's status.
///
/// See also:
///   * [PermissionAlertWidget] The widget displaying app
///   permission related information to the user along with a callback to grant
///   missing permissions.
class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LocationServiceAlert(),
        PermissionAlertWidget(
          title: LocaleKeys.permissions.notifications.alert
              .title()
              .translate(context),
          body: LocaleKeys.permissions.notifications.alert
              .body()
              .translate(context),
          permissionType: PermissionType.notifications,
        ),
        PermissionAlertWidget(
          title:
              LocaleKeys.permissions.location.alert.title().translate(context),
          body: LocaleKeys.permissions.location.alert.body().translate(context),
          permissionType: PermissionType.location,
        ),
      ],
    );
  }
}
