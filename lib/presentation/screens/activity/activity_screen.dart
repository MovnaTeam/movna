import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/domain/entities/notification_config.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/blocs/permissions_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/activity/activity_screen_content.dart';

/// The screen displaying the current activity.
///
/// This widget initializes cubits but leaves content rendering to
/// [ActivityScreenContent].
///
/// See also:
///   * [PermissionsCubit] The cubit managing app permissions.
///   * [ActivityCubit] The cubit managing an ongoing activity.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
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
        BlocProvider<ActivityCubit>(
          lazy: false,
          create: (providerContext) {
            return injector(
              param1: ActivityCubitParams(
                notificationConfig: NotificationConfig(
                  title: LocaleKeys.foreground_notification
                      .title()
                      .translate(context),
                  text: LocaleKeys.foreground_notification
                      .text()
                      .translate(context),
                ),
                permissionsCubit: providerContext.read<PermissionsCubit>(),
              ),
            )..listenToLocation();
          },
        ),
      ],
      child: const ActivityScreenContent(),
    );
  }
}
