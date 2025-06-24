import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/widgets/none_widget.dart';

class ActivityRealTimeStatsView extends StatelessWidget {
  const ActivityRealTimeStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: BlocSelector<ActivityCubit, ActivityState, Duration?>(
            selector: (state) => state.activity?.duration,
            builder: (BuildContext context, duration) => ActivityDurationWidget(
              duration: duration,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: BlocSelector<ActivityCubit, ActivityState, double?>(
                selector: (state) => state.activity?.distanceInMeters,
                builder: (BuildContext context, distance) {
                  var value = distance;
                  var decimals = 0;
                  var unit = LocaleKeys.units.metersShort().translate(context);
                  if (distance != null && distance >= 1000) {
                    value = distance / 1000;
                    decimals = 1;
                    unit =
                        LocaleKeys.units.kilometersShort().translate(context);
                  }
                  return ActivityRealTimeStatWidget(
                    title: LocaleKeys.activity.statistics
                        .distance()
                        .translate(context),
                    value: value,
                    unit: unit,
                    decimals: decimals,
                  );
                },
              ),
            ),
            Expanded(
              child: BlocSelector<LocationCubit, LocationCubitState, double?>(
                selector: (state) =>
                    state.location?.location.speedInMetersPerSecond,
                builder: (BuildContext context, speed) =>
                    ActivityRealTimeStatWidget(
                  title:
                      LocaleKeys.activity.statistics.speed().translate(context),
                  value: speed != null ? speed * 3600 / 1000 : speed,
                  unit: LocaleKeys.units
                      .kilometersPerHourShort()
                      .translate(context),
                  decimals: 1,
                ),
              ),
            ),
            Expanded(
              child: BlocSelector<ActivityCubit, ActivityState, double?>(
                selector: (state) =>
                    state.activity?.averageSpeedInMetersPerSecond,
                builder: (BuildContext context, speed) =>
                    ActivityRealTimeStatWidget(
                  title: LocaleKeys.activity.statistics
                      .averageSpeed()
                      .translate(context),
                  value: speed != null ? speed * 3600 / 1000 : speed,
                  unit: LocaleKeys.units
                      .kilometersPerHourShort()
                      .translate(context),
                  decimals: 1,
                ),
              ),
            ),
          ],
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

class ActivityDurationWidget extends StatelessWidget {
  const ActivityDurationWidget({
    super.key,
    this.duration,
  });

  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    int? hours;
    int? minutes;
    int? seconds;
    if (duration != null) {
      hours = duration!.inHours;
      minutes = duration!.inMinutes - hours * Duration.minutesPerHour;
      seconds = duration!.inSeconds -
          hours * Duration.minutesPerHour -
          minutes * Duration.secondsPerMinute;
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Text(
        style: DefaultTextStyle.of(context).style.apply(
            fontSizeFactor: 3.0,
            fontWeightDelta: 5,
              color: Theme.of(context).colorScheme.primary,
            ),
        '${hours != null ? NumberFormat('00').format(hours) : '--'}:'
        '${minutes != null ? NumberFormat('00').format(minutes) : '--'}:'
        '${seconds != null ? NumberFormat('00').format(seconds) : '--'}',
      ),
    );
  }
}
