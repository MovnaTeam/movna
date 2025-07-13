import 'dart:collection';
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
              child: _buildStateLoaded(context, activities),
            ),
        };
      },
    );
  }

  /// The width of one bar of the bar chart.
  static const barWidth = 16.0;

  Widget _buildStateLoaded(
    BuildContext context,
    List<Activity> activities,
  ) {
    final (monthlySumBySport, presentSports) = _prepareActivityData(activities);

    final lineBarsData = <LineChartBarData>[];
    final betweenBarsData = <BetweenBarsData>[];
    double maxY = 1.0;

    final colors = _createStepColors(
      Theme.of(context).colorScheme.primary,
      presentSports.length,
    );

    if (monthlySumBySport.isNotEmpty) {
      for (final (sportIndex, sport) in presentSports.indexed) {
        final spots = <FlSpot>[];
        for (final (index, MapEntry(key: dateGroup, value: sumsBySport))
            in monthlySumBySport.entries.indexed) {
          final thisMonthThisSportSum = sumsBySport[sport] ?? 0;
          // Add height of previous graph to stack curves.
          final y = thisMonthThisSportSum +
              (sportIndex == 0
                  ? 0
                  : lineBarsData[sportIndex - 1].spots[index].y);
          spots.add(FlSpot(_dateTimeToXValue(dateGroup), y));
          maxY = max(y, maxY);
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

    final leftAxisTitle =
        '${LocaleKeys.activity.statistics.distance().translate(context)}'
        ' '
        '(${LocaleKeys.units.kilometersShort().translate(context)})';

    const axisTitlesSpace = 8.0;
    const magicReservedSizeForLabelsMultiplier = 1.1;
    final maxXLabelSize = _xLabelMaximumSize(monthlySumBySport.keys);

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
                      return SideTitleWidget(
                        meta: meta,
                        space: axisTitlesSpace,
                        child: _xValueToLabel(value).$1,
                      );
                    },
                    reservedSize: axisTitlesSpace +
                        maxXLabelSize.height *
                            magicReservedSizeForLabelsMultiplier,
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(leftAxisTitle),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize:
                        axisTitlesSpace + _getLeftSideTitlesSize(maxY / 1_000),
                    interval: _getYGridInterval(maxY),
                    maxIncluded: false,
                    minIncluded: false,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      space: axisTitlesSpace,
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
                horizontalInterval: _getYGridInterval(maxY),
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
            ),
          ),
        ),
      ],
    );
  }

  double _getYGridInterval(double maxY) {
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
    return textPainter.width;
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

  /// Groups given activities by month, then by sport.
  ///
  /// Also ensures that there is no missing entry between two dates. For
  /// instance if the keys `DateTime(1999, 1)` and `DateTime(1999, 4)` are
  /// present, then so do `DateTime(1999, 2)` and `DateTime(1999, 3)`.
  ///
  /// Also returns the set of all encountered sports.
  (SplayTreeMap<DateTime, Map<Sport, double>>, Set<Sport>) _prepareActivityData(
    List<Activity> activities,
  ) {
    final monthlySumsMeters = SplayTreeMap<DateTime, Map<Sport, double>>();
    // What sports are concerned by this activity set.
    final presentSports = <Sport>{};

    for (final activity in activities) {
      final dateGroup =
          DateTime(activity.startTime.year, activity.startTime.month);
      final sport = activity.sport ?? Sport.other;

      presentSports.add(sport);

      if (monthlySumsMeters.isEmpty) {
        monthlySumsMeters[dateGroup] = {};
      } else if (!monthlySumsMeters.containsKey(dateGroup)) {
        // Ensure all keys are present, there is no missing month.
        if (dateGroup.isBefore(monthlySumsMeters.firstKey()!)) {
          while (!monthlySumsMeters.containsKey(dateGroup)) {
            final DateTime(year: firstYear, month: firstMonth) =
                monthlySumsMeters.firstKey()!;
            monthlySumsMeters[DateTime(
              firstMonth == 1 ? firstYear - 1 : firstYear,
              firstMonth == 1 ? DateTime.monthsPerYear : firstMonth - 1,
            )] = {};
          }
        } else {
          while (!monthlySumsMeters.containsKey(dateGroup)) {
            final DateTime(year: lastYear, month: lastMonth) =
                monthlySumsMeters.lastKey()!;
            monthlySumsMeters[DateTime(
              lastMonth == DateTime.monthsPerYear ? lastYear + 1 : lastYear,
              lastMonth == DateTime.monthsPerYear ? 1 : lastMonth + 1,
            )] = {};
          }
        }
      }

      monthlySumsMeters[dateGroup]![sport] =
          (monthlySumsMeters[dateGroup]![sport] ?? 0) +
              (activity.distanceInMeters ?? 0);
    }
    return (monthlySumsMeters, presentSports);
  }

  double _dateTimeToXValue(DateTime dateTime) =>
      dateTime.millisecondsSinceEpoch.toDouble();
  DateTime _xValueToDateTime(double x) =>
      DateTime.fromMillisecondsSinceEpoch(x.toInt());

  /// Convert a chart x value (representing a DateTime in milliseconds since
  /// Epoch) in its Widget label, with the size it will take.
  (Widget, Size) _xValueToLabel(double x) {
    final text =
        DateFormat.yMMM(Platform.localeName).format(_xValueToDateTime(x));
    final painter = TextPainter(
      textDirection: dui.TextDirection.ltr,
      text: TextSpan(text: text),
    )..layout();
    return (
      RotatedBox(
        quarterTurns: 1,
        child: Text(text),
      ),
      painter.size.flipped
    );
  }

  Size _xLabelMaximumSize(Iterable<DateTime> dateTimes) {
    var maxSize = Size(0, 0);
    for (final dateTime in dateTimes) {
      final size = _xValueToLabel(_dateTimeToXValue(dateTime)).$2;
      maxSize = Size(
        max(maxSize.width, size.width),
        max(maxSize.height, size.height),
      );
    }
    return maxSize;
  }
}
