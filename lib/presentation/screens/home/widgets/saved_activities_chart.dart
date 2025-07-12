import 'dart:io';
import 'dart:math';
import 'dart:ui' as dui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/statistics_cubit.dart';
import 'package:movna/presentation/extensions/sport_color_extension.dart';
import 'package:movna/presentation/extensions/sport_translation_extension.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/widgets/loading_indicator.dart';
import 'package:movna/presentation/screens/common/widgets/none_widget.dart';
import 'package:movna/presentation/screens/home/widgets/legend_widget.dart';

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

  /// The width of one bar of the bar chart.
  static const barWidth = 16.0;

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
    double maxY = 1.0;
    if (sortedKeys.isNotEmpty) {
      for (int month = sortedKeys.first; month <= sortedKeys.last; month++) {
        final sumsBySport = monthlySumsMeters[month];

        final rods = <BarChartRodData>[];
        double y = 0;

        // Determine which sport is on top of the rods in order to be able to
        // round it.
        Sport lastNonZeroSport = Sport.other;
        for (final sport in presentSports) {
          final thisMonthThisSportSum = sumsBySport?[sport] ?? 0;
          if (thisMonthThisSportSum == 0) continue;
          lastNonZeroSport = sport;
        }

        for (final sport in presentSports) {
          // Convert to km
          final thisMonthThisSportSum = sumsBySport?[sport] ?? 0;

          if (thisMonthThisSportSum == 0) continue;

          rods.add(
            BarChartRodData(
              fromY: y,
              toY: y + thisMonthThisSportSum,
              color: sport.toColor(context),
              width: barWidth,
              borderRadius: sport == lastNonZeroSport
                  ? BorderRadius.only(
                      topLeft: Radius.circular(barWidth / 2),
                      topRight: Radius.circular(barWidth / 2),
                    )
                  : BorderRadius.all(Radius.zero),
            ),
          );
          y += thisMonthThisSportSum;
        }
        maxY = max(maxY, y);

        spots.add(
          BarChartGroupData(
            x: month,
            barRods: rods,
            groupVertically: true,
          ),
        );
        final year = (month / DateTime.monthsPerYear).toInt();
        final monthInYear = month.remainder(DateTime.monthsPerYear) + 1;
        final displayYear = monthInYear == 1 || month == sortedKeys.firstOrNull;
        final label = (displayYear
                ? DateFormat.yMMM(Platform.localeName)
                : DateFormat.MMM(Platform.localeName))
            .format(
          DateTime(year, monthInYear),
        );
        labels[month] = label;
      }
    }

    return Column(
      children: [
        presentSports.length > 1
            ? LegendsListWidget(
                legends: presentSports
                    .map(
                      (sport) => Legend(
                        sport.translatable().translate(context),
                        sport.toColor(context),
                      ),
                    )
                    .toList(),
              )
            : const NoneWidget(),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: spots,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final label = labels[value.toInt()];
                      return SideTitleWidget(
                        meta: meta,
                        angle: pi / 4,
                        child: Text(label ?? ''),
                      );
                    },
                    reservedSize: _getBottomSideTitlesSize(labels.values),
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                      '${LocaleKeys.activity.statistics.distance().translate(
                            context,
                          )}'
                      ' (${LocaleKeys.units.kilometersShort().translate(
                            context,
                          )})'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: _getLeftSideTitlesSize(maxY / 1_000),
                    interval: _getGridInterval(maxY),
                    maxIncluded: false,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text((value / 1_000).toInt().toString()),
                    ),
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getGridInterval(maxY),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Theme.of(context).colorScheme.secondary,
                  dashArray: [10, 0],
                  strokeWidth: 0.5,
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: _getTopY(maxY),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (group) =>
                      Theme.of(context).colorScheme.primaryContainer,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      ((rod.toY - rod.fromY) / 1_000).toStringAsFixed(3),
                      TextStyle(
                        color: rod.color,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getGridInterval(double maxY) {
    return _getTopY(maxY) / 10;
  }

  double _getPreviousPowerOf10(double value) {
    double log10(double v) => log(v) / log(10.0);
    return pow(10.0, log10(value).toInt()).toDouble();
  }

  /// Returns the next multiple of the previous power of ten.
  /// Examples :
  /// - 15 -> 20
  /// - 78 -> 80
  /// - 259 -> 300
  /// - 4589 -> 5000
  double _getTopY(double maxY) {
    final previousPowerOf10 = _getPreviousPowerOf10(maxY);
    final nextMultipleOfPreviousPowerOf10 =
        ((maxY / previousPowerOf10) + 1).toInt() * previousPowerOf10;
    return nextMultipleOfPreviousPowerOf10;
  }

  double _getLeftSideTitlesSize(double maxY) {
    // Compute width of next power of 10,
    final textPainter = TextPainter(
      text:
          TextSpan(text: (_getPreviousPowerOf10(maxY) * 10).toInt().toString()),
      textDirection: dui.TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width * 1.2;
  }

  double _getBottomSideTitlesSize(Iterable<String> labels) {
    return labels.isEmpty
        ? 0
        : labels
            .map(
              (label) => (TextPainter(
                textDirection: dui.TextDirection.ltr,
                text: TextSpan(
                  text: label,
                ),
              )..layout())
                  .width,
            )
            .reduce(max);
  }
}
