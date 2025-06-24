import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';
import 'package:movna/presentation/screens/common/widgets/none_widget.dart';

class ActivityRealTimeStatsView extends StatelessWidget {
  const ActivityRealTimeStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: BlocSelector<ActivityCubit, ActivityState, double?>(
            selector: (state) => state.activity?.distanceInMeters,
            builder: (BuildContext context, distance) =>
                ActivityRealTimeStatWidget(
              title: 'Distance', // TODO translate
              value: distance,
              unit: 'm',
            ),
          ),
        ),
        Expanded(
          child: BlocSelector<LocationCubit, LocationCubitState, double?>(
            selector: (state) =>
                state.location?.location.speedInMetersPerSecond,
            builder: (BuildContext context, speed) =>
                ActivityRealTimeStatWidget(
              title: 'Speed', // TODO translate
              value: speed,
              unit: 'm/s',
              decimals: 1,
            ),
          ),
        ),
        Expanded(
          child: BlocSelector<ActivityCubit, ActivityState, double?>(
            selector: (state) => state.activity?.averageSpeedInMetersPerSecond,
            builder: (BuildContext context, speed) =>
                ActivityRealTimeStatWidget(
              title: 'Average Speed', // TODO translate
              value: speed,
              unit: 'm/s',
              decimals: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class ActivityRealTimeStatWidget extends StatelessWidget {
  const ActivityRealTimeStatWidget({
    super.key,
    this.value,
    this.title,
    this.unit,
    this.decimals = 0,
  });

  final double? value;
  final String? title;
  final String? unit;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          title != null ? Center(child: Text(title!)) : NoneWidget(),
          Center(
            child: Text(
              style: DefaultTextStyle.of(context).style.apply(
                  fontSizeFactor: 2.0,
                  fontWeightDelta: 5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              value?.toStringAsFixed(decimals) ?? '-',
            ),
          ),
          unit != null ? Center(child: Text(unit!)) : NoneWidget(),
        ],
      ),
    );
  }
}
