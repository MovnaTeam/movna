import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/location_service_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/activity/views/notifications/activity_notification.dart';
import 'package:movna/presentation/theme/app_theme.dart';
import 'package:movna/presentation/widgets/none_widget.dart';

/// Displays an alert to inform the user the location service is disabled.
///
/// The alert contains a CTA which tries to enable the location service on tap.
///
/// See [LocationServiceCubit] the cubit responsible for interacting with the
/// location service.
///
/// See [ActivityNotificationWidget] for more information on the alert
/// rendering.
class ActivityLocationServiceNotification extends StatelessWidget {
  const ActivityLocationServiceNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationServiceCubit, LocationServiceState>(
      builder: (context, state) {
        final status = state.whenOrNull(loaded: (status) => status);
        if (status == LocationServiceStatus.disabled) {
          return ActivityNotificationWidget(
            title: LocaleKeys.location.notification.title().translate(context),
            body: LocaleKeys.location.notification.body().translate(context),
            icon: Icons.location_disabled,
            iconBackground: Theme.of(context).customColors.warningContainer,
            iconForeground: Theme.of(context).customColors.onWarningContainer,
            action: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                textStyle: Theme.of(context).textTheme.labelSmall,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: context
                  .read<LocationServiceCubit>()
                  .requestLocationService,
              child: Text(
                LocaleKeys.location.notification.enable().translate(context),
              ),
            ),
          );
        }
        return const NoneWidget();
      },
    );
  }
}
