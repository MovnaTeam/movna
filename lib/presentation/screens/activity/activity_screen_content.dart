import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/assets.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/router/router.dart';
import 'package:movna/presentation/screens/activity/views/activity_real_time_stats_view.dart';
import 'package:movna/presentation/screens/common/views/alerts/alerts_view.dart';
import 'package:movna/presentation/screens/common/views/map/activity_map_view.dart';
import 'package:movna/presentation/screens/common/widgets/svg_themed_widget.dart';

/// Displays the content of the activity screen.
///
/// Displays the [ActivityMapView] overlaid by eventual
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
        child: Scaffold(
          appBar: AppBar(
            title: const Center(
              child: SvgThemedWidget(svgAsset: Assets.movnaLogo),
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  ActivityRealTimeStatsView(),
                  Expanded(child: ActivityMapView()),
                ],
              ),
              AlertsView(),
            ],
          ),
        ),
      ),
    );
  }
}
