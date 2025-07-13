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

    final sortedKeys = monthlySumsMeters.keys.toList(growable: false)..sort();
    final lineBarsData = <LineChartBarData>[];
    final betweenBarsData = <BetweenBarsData>[];
    final labels = <int, String>{};
    double maxY = 1.0;

    final colors = _createStepColors(
      Theme.of(context).colorScheme.primary,
      presentSports.length,
    );

    if (sortedKeys.isNotEmpty) {
      for (final (sportIndex, sport) in presentSports.indexed) {
        final spots = <FlSpot>[];
        for (int month = sortedKeys.first; month <= sortedKeys.last; month++) {
          final thisMonthThisSportSum = monthlySumsMeters[month]?[sport] ?? 0;
          // Add height of previous graph to stack curves.
          final y = thisMonthThisSportSum +
              (sportIndex == 0
                  ? 0
                  : lineBarsData[sportIndex - 1]
                      .spots[month - sortedKeys.first]
                      .y);
          spots.add(FlSpot(month.toDouble(), y));
          maxY = max(y, maxY);

          final year = (month / DateTime.monthsPerYear).toInt();
          final monthInYear = month.remainder(DateTime.monthsPerYear) + 1;
         
          labels[month] = DateFormat.MMM(Platform.localeName)
              .format(DateTime(year, monthInYear));
        }

        final color = colors[sportIndex];
        final colorUnderCurve = color.withAlpha(128);

        lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) => spot.y != 0,
            ),
            belowBarData: BarAreaData(
              show: sportIndex == 0,
              color: colorUnderCurve,
            ),
          ),
        );

        if (sportIndex > 0) {
          betweenBarsData.add(
            BetweenBarsData(
              fromIndex: sportIndex - 1,
              toIndex: sportIndex,
              color: colorUnderCurve,
            ),
          );
        }
      }
    }

    // Add a year label in the background between every June and July.
    final verticalLines = <VerticalLine>[];
    for (int month = sortedKeys.first; month <= sortedKeys.last; month++) {
      if (month.remainder(DateTime.monthsPerYear) != 0) continue;
      verticalLines.add(
        VerticalLine(
          x: month.toDouble() + 0.5,
          strokeWidth: 0.5,
          color: Theme.of(context).colorScheme.secondary,
          label: VerticalLineLabel(
            style: DefaultTextStyle.of(context).style.apply(
                  fontSizeFactor: 2.0,
                  fontWeightDelta: 5,
                  color: Theme.of(context).colorScheme.secondary.withAlpha(128),
                ),
            alignment: Alignment.centerRight,
            show: true,
            labelResolver: (line) =>
                (line.x / DateTime.monthsPerYear).toInt().toString(),
            direction: LabelDirection.vertical,
          ),
        ),
      );
    }

    final leftAxisTitle =
        '${LocaleKeys.activity.statistics.distance().translate(context)}'
        ' '
        '(${LocaleKeys.units.kilometersShort().translate(context)})';

    return Column(
      children: [
        presentSports.length > 1
            ? LegendsListWidget(
                legends: presentSports.indexed
                    .map(
                      (sport) => Legend(
                        sport.$2.translatable().translate(context),
                        colors[sport.$1],
                      ),
                    )
                    .toList(),
              )
            : const NoneWidget(),
        Expanded(
          child: LineChart(
            LineChartData(
              lineBarsData: lineBarsData,
              betweenBarsData: betweenBarsData,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    minIncluded: false,
                    maxIncluded: false,
                    getTitlesWidget: (value, meta) {
                      final label = labels[value.toInt()];
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(label ?? ''),
                      );
                    },
                    reservedSize: _getBottomSideTitlesSize(labels.values),
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(leftAxisTitle),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: _getLeftSideTitlesSize(maxY / 1_000),
                    interval: _getGridInterval(maxY),
                    maxIncluded: false,
                    minIncluded: false,
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
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (group) =>
                      Theme.of(context).colorScheme.primaryContainer,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.indexed
                        .map(
                          (pair) => LineTooltipItem(
                            ((pair.$2.y -
                                        (pair.$1 < touchedSpots.length - 1
                                            ? touchedSpots[pair.$1 + 1].y
                                            : 0)) /
                                    1_000)
                                .toStringAsFixed(3),
                            TextStyle(color: pair.$2.bar.color),
                          ),
                        )
                        .toList();
                  },
                ),
              ),
              extraLinesData: ExtraLinesData(
                extraLinesOnTop: false,
                verticalLines: verticalLines,
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

  /// Crate list of [count] colors that go from white to [target].
  List<Color> _createStepColors(Color target, int count) {
    final primary = HSVColor.fromColor(target);
    return List.generate(
      count,
      (i) => primary
          .withValue(1 - (primary.value * (i + 1) / count))
          .withSaturation(primary.saturation * (i + 1) / count)
          .toColor(),
    );
  }
}
