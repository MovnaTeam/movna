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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<StatisticsCubit, StatisticsState>(
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
      ),
    );
  }

  Widget _buildStateLoaded(
    BuildContext context,
    List<Activity> activities,
  ) {
    final (monthlySumBySport, presentSports) = _prepareActivityData(activities);

    final sportToColor = Map.fromIterables(
      presentSports,
      _createStepColors(
        Theme.of(context).colorScheme.primary,
        presentSports.length,
      ),
    );

    if (activities.isEmpty) {
      return Center(
        child: Text(LocaleKeys.home.tabs.progress.noData().translate(context)),
      );
    }

    return Column(
      children: [
        Builder(
          builder: (context) => _buildChartLegend(
            context,
            sportToColor,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => _buildChart(
              context,
              monthlySumBySport,
              sportToColor,
              constraints,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend(
    BuildContext context,
    Map<Sport, Color> sportColorMapping,
  ) {
    return sportColorMapping.length > 1
        ? LegendsListWidget(
            legends: sportColorMapping.entries
                .map(
                  (sportToColor) => Legend(
                    sportToColor.key.translatable().translate(context),
                    sportToColor.value,
                  ),
                )
                .toList(),
          )
        : const NoneWidget();
  }

  Widget _buildChart(
    BuildContext context,
    SplayTreeMap<DateTime, Map<Sport, double>> preparedData,
    Map<Sport, Color> sportColorMapping,
    BoxConstraints constraints,
  ) {
    final lineBarsData = <LineChartBarData>[];
    final betweenBarsData = <BetweenBarsData>[];
    double maxY = 1.0;

    if (preparedData.isNotEmpty) {
      for (final (sportIndex, sport) in sportColorMapping.keys.indexed) {
        final spots = <FlSpot>[];
        for (final (index, MapEntry(key: dateGroup, value: sumsBySport))
            in preparedData.entries.indexed) {
          final thisMonthThisSportSum = sumsBySport[sport] ?? 0;
          // Add height of previous graph to stack curves.
          final y = thisMonthThisSportSum +
              (sportIndex == 0
                  ? 0
                  : lineBarsData[sportIndex - 1].spots[index].y);
          spots.add(FlSpot(_dateTimeToXValue(dateGroup), y));
          maxY = max(y, maxY);
        }

        final color = sportColorMapping[sport]!;
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

    /// The space between the axises and their labels.
    const axisTitlesSpace = 8.0;

    /// Applied to the labels maximum size to reserve more space.
    /// Do not ask me why this is necessary.
    const magicReservedSizeForLabelsMultiplier = 1.2;

    final maxXLabelSize = _xLabelMaximumSize(preparedData.keys);
    final xLabelsReservedHeight = axisTitlesSpace +
        maxXLabelSize.height * magicReservedSizeForLabelsMultiplier;

    // Cheating here, as we know the y labels are numbers, the largest one is
    // just the highest one, multiplied for security.
    final maxYLabelSize = _yLabelMaximumSize([maxY * 10]);
    final yLabelsReservedWidth = axisTitlesSpace +
        maxYLabelSize.width * magicReservedSizeForLabelsMultiplier;
    final maxYLabelsCount =
        (constraints.maxHeight - xLabelsReservedHeight) / maxYLabelSize.height;
    final topY = _getTopY(maxY);
    final yLabelsInterval = max(
      1_000.0,
      ((topY / (maxYLabelsCount / 2)) / 1_000).toInt().toDouble() * 1_000,
    );

    final (yAxisTitle, yAxisTitleSize) = _getYAxisTitle(context);
    final yAxisTitleReservedWidth =
        yAxisTitleSize.flipped.width * magicReservedSizeForLabelsMultiplier;

    final maxXLabelsCount = (constraints.maxWidth -
            yAxisTitleReservedWidth -
            yLabelsReservedWidth) /
        maxXLabelSize.width;
    final xLabelsInterval =
        max(1.0, preparedData.length / (maxXLabelsCount / 2))
                .toInt()
                .toDouble() *
            _dateTimeToXValue(
              DateTime.fromMillisecondsSinceEpoch(
                Duration(days: 31).inMilliseconds,
              ),
            );

    return LineChart(
      LineChartData(
        lineBarsData: lineBarsData,
        betweenBarsData: betweenBarsData,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              minIncluded: false,
              maxIncluded: false,
              interval: xLabelsInterval,
              reservedSize: xLabelsReservedHeight,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                space: axisTitlesSpace,
                child: _xValueToLabel(value).$1,
              ),
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: yAxisTitle,
            axisNameSize: yAxisTitleReservedWidth,
            sideTitles: SideTitles(
              showTitles: true,
              minIncluded: false,
              maxIncluded: false,
              interval: yLabelsInterval,
              reservedSize: yLabelsReservedWidth,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                space: axisTitlesSpace,
                child: Text((value / 1_000).toInt().toString()),
              ),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yLabelsInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.secondary,
            dashArray: [10, 0],
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: _getNextMultipleOfPreviousPowerOfTen(maxY),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (group) => Theme.of(context).colorScheme.surface,
            getTooltipItems: (touchedSpots) => _getTooltipItems(
              context,
              touchedSpots,
              sportColorMapping.keys.toList(),
            ),
            tooltipBorder:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }

  List<LineTooltipItem?> _getTooltipItems(
    BuildContext context,
    List<LineBarSpot> touchedSpots,
    List<Sport> sports,
  ) {
    // Spots are given in some random order AND there is no way to give the
    // tooltip a title. This method is serious hack just to display a date.
    return (touchedSpots
          ..sort(
            (a, b) => b.barIndex - a.barIndex,
          ))
        .map(
      (spot) {
        final distanceInKm = (spot.y -
                (spot.barIndex == 0
                    ? 0
                    : touchedSpots
                        .firstWhere(
                          (other) => other.barIndex == spot.barIndex - 1,
                        )
                        .y)) /
            1_000;
        final sport = sports[spot.barIndex];
        return LineTooltipItem(
          spot.barIndex != touchedSpots.length - 1
              ? ''
              : '${DateFormat.yMMM(Platform.localeName).format(
                  _xValueToDateTime(spot.x),
                )}\n',
          DefaultTextStyle.of(context).style.apply(
                fontWeightDelta: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
          children: [
            TextSpan(
              text: '${sport.translatable().translate(context)}'
                  ' : '
                  '${distanceInKm.toStringAsFixed(3)}',
              style: DefaultTextStyle.of(context).style.apply(
                    fontWeightDelta: 0,
                    color: spot.bar.color,
                  ),
            ),
          ],
        );
      },
    ).toList();
  }

  (Widget, Size) _getYAxisTitle(BuildContext context) {
    final text =
        '${LocaleKeys.activity.statistics.distance().translate(context)}'
        ' '
        '(${LocaleKeys.units.kilometersShort().translate(context)})';
    final painter = TextPainter(
      textDirection: dui.TextDirection.ltr,
      text: TextSpan(text: text),
    )..layout();
    return (Text(text), painter.size);
  }

  /// Returns the next multiple of the previous power of ten.
  /// Examples :
  /// - 15 -> 20
  /// - 78 -> 80
  /// - 259 -> 300
  /// - 4589 -> 5000
  double _getNextMultipleOfPreviousPowerOfTen(double maxY) {
    double getPreviousPowerOf10(double value) {
      double log10(double v) => log(v) / log(10.0);
      return pow(10.0, log10(value).toInt()).toDouble();
    }

    if (maxY <= 0) return 0;

    final previousPowerOf10 = getPreviousPowerOf10(maxY);
    final nextMultipleOfPreviousPowerOf10 =
        ((maxY / previousPowerOf10) + 1).toInt() * previousPowerOf10;
    return nextMultipleOfPreviousPowerOf10;
  }

  /// Crate list of [count] colors that go from white to [target].
  List<Color> _createStepColors(Color target, int count) {
    final primary = HSVColor.fromColor(target);
    return List.generate(
      count,
      (i) => primary
          .withValue(
            (primary.value * (i + 1) / count) + (1 - ((i + 1) / count)),
          )
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

  (Widget, Size) _yValueToLabel(double y) {
    final text = (y / 1_000).toInt().toString();
    final painter = TextPainter(
      textDirection: dui.TextDirection.ltr,
      text: TextSpan(text: text),
    )..layout();
    return (Text(text), painter.size);
  }

  Size _yLabelMaximumSize(Iterable<double> yValues) {
    var maxSize = Size(0, 0);
    for (final y in yValues) {
      final size = _yValueToLabel(y).$2;
      maxSize = Size(
        max(maxSize.width, size.width),
        max(maxSize.height, size.height),
      );
    }
    return maxSize;
  }
}
