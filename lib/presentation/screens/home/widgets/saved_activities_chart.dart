import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/statistics_cubit.dart';
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
              child: _buildActivitiesListView(context, activities),
            ),
        };
      },
    );
  }

  Widget _buildActivitiesListView(
      BuildContext context, List<Activity> activities) {
    final Map<String, double> monthlySums = {};

    for (final activity in activities) {
      final monthKey = DateFormat('yyyy-MM').format(activity.startTime);
      monthlySums[monthKey] =
          (monthlySums[monthKey] ?? 0) + (activity.distanceInMeters ?? 0);
    }
    // Convert to km.
    monthlySums.updateAll((_, value) => value / 1_000);
    logger.d(monthlySums);

    final sortedKeys = monthlySums.keys.toList()..sort();
    final spots = <BarChartGroupData>[];
    final labels = <int, String>{};

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final sum = monthlySums[key]!;
      spots.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: sum,
              color: Theme.of(context).colorScheme.primary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      labels[i] = key;
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
                return Text(
                  label != null
                      ? DateFormat('MMM').format(DateTime.parse('$label-01'))
                      : '',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget:
                Text('${LocaleKeys.activity.statistics.distance().translate(
                          context,
                        )}'
                    ' (${LocaleKeys.units.kilometersPerHourShort().translate(
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
