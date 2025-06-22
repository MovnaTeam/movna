import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/domain/entities/location_service_status.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/location_service_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/views/alerts/alert_transition_widget.dart';
import 'package:movna/presentation/screens/common/views/alerts/alert_widget.dart';
import 'package:movna/presentation/screens/common/widgets/none_widget.dart';
import 'package:movna/presentation/theme/app_theme.dart';

/// Displays an alert to inform the user the location service is disabled.
///
/// The alert contains a CTA which tries to enable the location service on tap.
///
/// See [LocationServiceCubit] the cubit responsible for interacting with the
/// location service.
///
/// See [AlertWidget] for more information on the alert
/// rendering.
class LocationServiceAlert extends StatelessWidget {
  const LocationServiceAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationServiceCubit, LocationServiceState>(
      builder: (context, state) {
        final status = switch (state) {
          LocationServiceLoaded(:final status) => status,
          _ => null,
        };
        final Widget child;
        if (status == LocationServiceStatus.disabled) {
          child = AlertWidget(
            title: LocaleKeys.location.alert.title().translate(context),
            body: LocaleKeys.location.alert.body().translate(context),
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
              onPressed:
                  context.read<LocationServiceCubit>().requestLocationService,
              child: Text(
                LocaleKeys.location.alert.enable().translate(context),
              ),
            ),
          );
        } else {
          child = const NoneWidget();
        }
        return AlertTransitionWidget(child: child);
      },
    );
  }
}
