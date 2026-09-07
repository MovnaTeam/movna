import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/activity/views/activity_real_time_stats_view.dart';
import 'package:movna/presentation/screens/common/views/alerts/alerts_view.dart';
import 'package:movna/presentation/screens/common/views/map/activity_map_view.dart';
import 'package:movna/presentation/screens/common/widgets/none_widget.dart';
import 'package:movna/presentation/screens/home/start_activity_popup.dart';

/// Displays the content of the activity screen.
///
/// Displays the [ActivityMapView] overlaid by eventual
/// [ActivityAlert].
class ActivityScreenContent extends StatelessWidget {
  const ActivityScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          context.read<ActivityCubit>().stopActivity();
        },
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildRealTimeStats(context),
                Expanded(child: ActivityMapView()),
              ],
            ),
            _buildStartButton(context),
            AlertsView(),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) =>
      BlocBuilder<ActivityCubit, ActivityState>(
        builder: (context, state) {
          if (state case ActivityIdle()) {
            return Column(
              children: [
                Expanded(child: NoneWidget()),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder:
                            (modalContext) => BlocProvider.value(
                              value: context.read<ActivityCubit>(),
                              child: const StartActivityPopup(),
                        ),
                      );
                    },
                    child: Text(
                      LocaleKeys.home.startActivity().translate(context),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return NoneWidget();
          }
        },
      );

  Widget _buildRealTimeStats(BuildContext context) =>
      BlocBuilder<ActivityCubit, ActivityState>(
        builder: (context, state) {
          if (state case ActivityDone()) {
            return NoneWidget();
          } else {
            return ActivityRealTimeStatsView();
          }
        },
      );
}
