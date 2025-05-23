import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/permissions_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/activity/views/alerts/activity_alert_widget.dart';
import 'package:movna/presentation/screens/activity/views/alerts/alert_transition_widget.dart';
import 'package:movna/presentation/widgets/app_lifecycle_watcher.dart';
import 'package:movna/presentation/widgets/none_widget.dart';

enum PermissionType {
  notifications(Icons.notifications),
  location(Icons.my_location);

  const PermissionType(this.icon);

  final IconData icon;
}

/// A widget that displays a card indicating the user that a required app
/// permission has not been granted.
///
/// This widget is displayed only if the permission has been denied.
/// This widget contains an action for the user to grant the permission.
///
/// Additionally, this widget calls [PermissionsCubit.checkPermissions] when the
/// app is resumed.
/// Permissions can only be granted when app is in the background so any
/// permission check on app resume returns the latest permission status.
///
/// See also:
///   * [AppLifecycleWatcher] The widget that allows for registering callbacks
///   on app lifecycle change.
///   * [ActivityAlertWidget] The widget laying out and
///   rendering the displayed card.
///   * [PermissionsCubit] The cubit managing app permissions.
class ActivityPermissionAlertWidget extends StatelessWidget {
  const ActivityPermissionAlertWidget({
    required this.title,
    required this.body,
    required this.permissionType,
    super.key,
  });

  final String title;
  final String body;
  final PermissionType permissionType;

  @override
  Widget build(BuildContext context) {
    return AppLifecycleWatcher(
      onAppResumed: () {
        context.read<PermissionsCubit>().checkPermissions(
              const PermissionsCubitParams(
                requestLocation: true,
                requestNotifications: true,
              ),
              true,
            );
      },
      child: BlocBuilder<PermissionsCubit, PermissionsState>(
        builder: (context, state) {
          if (state
              case PermissionsLoaded(
                :final notificationPermission,
                :final locationPermission
              )) {
            final bool isPermissionGranted = switch (permissionType) {
              PermissionType.notifications =>
                notificationPermission?.getOrNull()?.isGranted ?? false,
              PermissionType.location =>
                locationPermission?.getOrNull()?.isGranted ?? false,
            };
            if (isPermissionGranted) {
              return AlertTransitionWidget(child: NoneWidget());
            }
            return ActivityAlertWidget(
              title: title,
              body: body,
              icon: permissionType.icon,
              iconBackground: Theme.of(context).colorScheme.errorContainer,
              iconForeground: Theme.of(context).colorScheme.onErrorContainer,
              action: ElevatedButton(
                onPressed: () async {
                  final permissionsCubit = context.read<PermissionsCubit>();
                  final callback = switch (permissionType) {
                    PermissionType.notifications =>
                      await permissionsCubit.getNotificationRequestMethod(true),
                    PermissionType.location =>
                      await permissionsCubit.getLocationRequestMethod(true)
                  };
                  callback();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  textStyle: Theme.of(context).textTheme.labelSmall,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  LocaleKeys.permissions.grant().translate(context),
                ),
              ),
            );
          } else {
            return AlertTransitionWidget(child: NoneWidget());
          }
        },
      ),
    );
  }
}
