import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/statistics_cubit.dart';
import 'package:movna/presentation/extensions/sport_color_extension.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/widgets/loading_indicator.dart';

class SavedActivitiesChart extends StatelessWidget {
  const SavedActivitiesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        return switch (state) {
          StatisticsStateInitial() ||
          StatisticsStateLoading() =>
            LoadingIndicator(),
          StatisticsStateError(/*:final fault*/) => Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
            ),
          StatisticsStateLoaded(:final activities) => Center(
              child: _buildActivitiesChart(context, activities),
            ),
        };
      },
    );
  }

  Widget _buildActivitiesChart(
    BuildContext context,
    List<Activity> activities,
  ) {
    // For each month (12*year+month), for each Sport, the sum of all distances.
    final Map<int, Map<Sport, double>> monthlySumsMeters = {};
    // What sports are concerned by this activity set.
    final Set<Sport> presentSports = {};

    for (final activity in activities) {
      final month = activity.startTime.year * DateTime.monthsPerYear +
          (activity.startTime.month - 1);
      final sport = activity.sport ?? Sport.other;

      presentSports.add(sport);

      if (!monthlySumsMeters.containsKey(month)) monthlySumsMeters[month] = {};

      monthlySumsMeters[month]![sport] =
          (monthlySumsMeters[month]![sport] ?? 0) +
              (activity.distanceInMeters ?? 0);
    }

    final sortedKeys = monthlySumsMeters.keys.toList()..sort();
    final spots = <BarChartGroupData>[];
    final labels = <int, String>{};
    if (sortedKeys.isNotEmpty) {
      for (int month = sortedKeys.first; month <= sortedKeys.last; month++) {
        final sumsBySport = monthlySumsMeters[month];

        final rods = <BarChartRodData>[];
        double y = 0;
        for (final sport in presentSports) {
          // Convert to km
          final thisMonthThisSportSum = (sumsBySport?[sport] ?? 0) / 1_000;
          rods.add(
            BarChartRodData(
              fromY: y,
              toY: y + thisMonthThisSportSum,
              color: sport.toColor(context),
              width: 16,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
          );
          y += thisMonthThisSportSum;
        }

        spots.add(
          BarChartGroupData(
            x: month,
            barRods: rods,
            groupVertically: true,
          ),
        );
        labels[month] = (month % DateTime.monthsPerYear).toString();
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: spots,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final label = labels[value.toInt()];
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    label?.toString() ?? '',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget:
                Text('${LocaleKeys.activity.statistics.distance().translate(
                          context,
                        )}'
                    ' (${LocaleKeys.units.kilometersShort().translate(
                          context,
                        )})'),
            sideTitles: SideTitles(showTitles: true),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
