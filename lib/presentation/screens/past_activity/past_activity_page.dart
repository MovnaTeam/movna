import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';
import 'package:movna/presentation/blocs/location_service_cubit.dart';
import 'package:movna/presentation/blocs/permissions_cubit.dart';
import 'package:movna/presentation/screens/common/activity_screen_content.dart';

class PastActivityPage extends StatelessWidget {
  const PastActivityPage({required this.activityId, super.key});

  final String activityId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<LocationServiceCubit>(create: (_) => injector()),
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
                  /*notificationConfig: NotificationConfig(
                    title: LocaleKeys.foreground_notification.title().translate(
                      context,
                    ),
                    text: LocaleKeys.foreground_notification.text().translate(
                      context,
                    ),
                  ),*/
                  permissionsCubit: providerContext.read<PermissionsCubit>(),
                  locationServiceCubit:
                      providerContext.read<LocationServiceCubit>(),
                ),
              )..listenToLocation();
            },
          ),
          BlocProvider<ActivityCubit>(
            lazy: false,
            create:
                (providerContext) =>
                    injector(param1: providerContext.read<LocationCubit>())
                      ..loadDone(activityId),
          ),
        ],
        child: const ActivityScreenContent(),
      ),
    );
  }
}