import 'package:flutter/material.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/activity/views/notifications/activity_location_service_notification.dart';
import 'package:movna/presentation/screens/activity/views/notifications/activity_permission_notification.dart';

/// This widget shows a variety of notification-formatted cards depending on the
/// app's status.
///
/// See also:
///   * [ActivityPermissionNotificationWidget] The widget displaying app
///   permission related information to the user along with a callback to grant
///   missing permissions.
class ActivityNotifications extends StatelessWidget {
  const ActivityNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ActivityLocationServiceNotification(),
        ActivityPermissionNotificationWidget(
          title: LocaleKeys.permissions.notifications.notification
              .title()
              .translate(context),
          body: LocaleKeys.permissions.notifications.notification
              .body()
              .translate(context),
          permissionType: PermissionType.notifications,
        ),
        ActivityPermissionNotificationWidget(
          title: LocaleKeys.permissions.location.notification
              .title()
              .translate(context),
          body: LocaleKeys.permissions.location.notification
              .body()
              .translate(context),
          permissionType: PermissionType.location,
        ),
      ],
    );
  }
}
