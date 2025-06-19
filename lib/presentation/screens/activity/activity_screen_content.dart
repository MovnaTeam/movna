import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/router/router.dart';
import 'package:movna/presentation/screens/activity/views/alerts/activity_alerts_view.dart';
import 'package:movna/presentation/screens/activity/views/map/activity_map_view.dart';

/// Displays the content of the activity screen.
///
/// Displays the [ActivityMapView] overlayed by eventual
/// [ActivityAlert].
class ActivityScreenContent extends StatelessWidget {
  const ActivityScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityCubit, ActivityState>(
      listener: (context, state) {
        if (state is ActivityDone) {
          const HomeRoute().go(context);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          context.read<ActivityCubit>().stopActivity();
        },
        child: const Stack(
          children: [
            ActivityMapView(),
            ActivityAlertsView(),
          ],
        ),
      ),
    );
  }
}
