import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';
import 'package:movna/presentation/blocs/location_service_cubit.dart';
import 'package:movna/presentation/blocs/permissions_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/views/map/activity_map_view.dart';
import 'package:movna/presentation/screens/common/widgets/none_widget.dart';
import 'package:movna/presentation/screens/home/start_activity_popup.dart';

/// This is the HomePage tab containing the start activity button.
class HomeActivityScreen extends StatelessWidget {
  const HomeActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          _buildMapWidget(context),
          SafeArea(
            bottom: true,
            child: Column(
              children: [
                Expanded(child: const NoneWidget()),
                Center(
                  child: ElevatedButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      builder: (context) => const StartActivityPopup(),
                    ),
                    child: Text(
                      LocaleKeys.home.startActivity().translate(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWidget(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationServiceCubit>(
          create: (_) => injector(),
        ),
        BlocProvider<PermissionsCubit>(
          lazy: false,
          create: (_) {
            return injector(
              param1: const PermissionsCubitParams(
                requestLocation: true,
                requestNotifications: true,
              ),
            )..requestPermissions();
          },
        ),
        BlocProvider<LocationCubit>(
          lazy: false,
          create: (providerContext) {
            return injector(
              param1: LocationCubitParams(
                // This should not be necessary here as we do not care about
                // getting location in the background on this screen, but it is
                // the first time the app gets the Geolocator location stream,
                // and it will not be closed immediately when switching screen,
                // resulting in Android not recreating it with a new
                // notification when called again. So a notification is added
                // here as a workaround, even if unnecessary on this screen.
                notificationConfig: NotificationConfig(
                  title: LocaleKeys.foreground_notification
                      .title()
                      .translate(context),
                  text: LocaleKeys.foreground_notification
                      .text()
                      .translate(context),
                ),
                permissionsCubit: providerContext.read<PermissionsCubit>(),
                locationServiceCubit:
                    providerContext.read<LocationServiceCubit>(),
              ),
            )..listenToLocation();
          },
        ),
      ],
      child: const ActivityMapView(),
    );
  }
}
