import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';
import 'package:movna/presentation/blocs/location_service_cubit.dart';
import 'package:movna/presentation/blocs/permissions_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/activity/activity_screen_content.dart';

part 'activity_screen.freezed.dart';

/// Parameters of the new Activity screen to display.
@freezed
abstract class ActivityScreenParams with _$ActivityScreenParams {
  const factory ActivityScreenParams({
    required Sport sport,
  }) = _ActivityScreenParams;
}

/// The screen displaying the current activity.
///
/// This widget initializes cubits but leaves content rendering to
/// [ActivityScreenContent].
///
/// See also:
///   * [PermissionsCubit] The cubit managing app permissions.
///   * [ActivityCubit] The cubit managing an ongoing activity.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({required this.parameters, super.key});

  final ActivityScreenParams parameters;

  @override
  Widget build(BuildContext context) {
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
        BlocProvider<ActivityCubit>(
          lazy: false,
          create: (providerContext) => injector(
            param1: ActivityCubitParams(
              locationCubit: providerContext.read<LocationCubit>(),
              sport: parameters.sport,
            ),
          ),
        ),
      ],
      child: const ActivityScreenContent(),
    );
  }
}
