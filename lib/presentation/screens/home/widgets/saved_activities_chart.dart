import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as dui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:json_locale/json_locale.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/statistics_cubit.dart';
import 'package:movna/presentation/extensions/sport_translation_extension.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/widgets/loading_indicator.dart';
import 'package:movna/presentation/screens/common/widgets/none_widget.dart';
import 'package:movna/presentation/screens/home/widgets/legend_widget.dart';

/// All time groups by which activities can be grouped by.
enum _GroupBy {
  day,
  month,
  year,
}

extension _GroupByTranslationExt on _GroupBy {
  Translatable translatable() => switch (this) {
        _GroupBy.day => LocaleKeys.units.day(),
        _GroupBy.month => LocaleKeys.units.month(),
        _GroupBy.year => LocaleKeys.units.year(),
      };
}

/// What can be displayed on the graph.
enum _DisplayOption {
  distance,
  duration,
}

extension _DisplayOptionTranslationExt on _DisplayOption {
  Translatable translatable() => switch (this) {
        _DisplayOption.distance => LocaleKeys.activity.statistics.distance(),
        _DisplayOption.duration => LocaleKeys.activity.statistics.duration(),
      };
}

class SavedActivitiesChartView extends StatefulWidget {
  const SavedActivitiesChartView({super.key});

  @override
  State<SavedActivitiesChartView> createState() =>
      SavedActivitiesChartViewState();
}

class SavedActivitiesChartViewState extends State<SavedActivitiesChartView> {
  final _groupBy = ValueNotifier(_GroupBy.month);
  final _displayOption = ValueNotifier(_DisplayOption.distance);
  final _cumulative = ValueNotifier(false);

  late final Listenable _chartConfig;

  @override
  void initState() {
    _chartConfig = Listenable.merge([_groupBy, _displayOption, _cumulative]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16.0,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.home.tabs.progress.savedActivitiesChart
                        .groupBy()
                        .translate(context),
                  ),
                  SizedBox(width: 8.0),
                  ValueListenableBuilder(
                    valueListenable: _groupBy,
                    builder: (context, groupBy, _) => DropdownButton(
                      value: groupBy,
                      onChanged: (_GroupBy? value) {
                        if (value == null) return;
                        _groupBy.value = value;
                      },
                      items: _GroupBy.values
                          .map<DropdownMenuItem<_GroupBy>>((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                            value.translatable().translate(context),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.home.tabs.progress.savedActivitiesChart
                        .displayOption()
                        .translate(context),
                  ),
                  SizedBox(width: 8.0),
                  ValueListenableBuilder(
                    valueListenable: _displayOption,
                    builder: (context, displayOption, _) => DropdownButton(
                      value: displayOption,
                      onChanged: (_DisplayOption? value) {
                        if (value == null) return;
                        _displayOption.value = value;
                      },
                      items: _DisplayOption.values
                          .map<DropdownMenuItem<_DisplayOption>>((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                            value.translatable().translate(context),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.home.tabs.progress.savedActivitiesChart
                        .cumulative()
                        .translate(context),
                  ),
                  SizedBox(width: 8.0),
                  ValueListenableBuilder(
                    valueListenable: _cumulative,
                    builder: (context, cumulative, _) => Checkbox(
                      value: cumulative,
                      onChanged: (value) {
                        if (value == null) return;
                        _cumulative.value = value;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          ListenableBuilder(
            listenable: _chartConfig,
            builder: (context, _) => Expanded(
              child: _SavedActivitiesChart(
                displayOption: _displayOption.value,
                groupBy: _groupBy.value,
                cumulative: _cumulative.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedActivitiesChart extends StatelessWidget {
  const _SavedActivitiesChart({
    required this.displayOption,
    required this.groupBy,
    required this.cumulative,
  });

  final _DisplayOption displayOption;
  final _GroupBy groupBy;
  final bool cumulative;

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

  Widget _buildStateLoaded(
    BuildContext context,
    List<Activity> activities,
  ) {
    final (sumsByDateGroup, presentSports) = _prepareActivityData(activities);

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
              sumsByDateGroup,
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
          final thisDateGroupThisSportSum = sumsBySport[sport] ?? 0;
          // Add height of previous graph to stack curves.
          final y = cumulative
              ? thisDateGroupThisSportSum +
                  ((index > 0 ? spots[index - 1].y : 0) +
                      (sportIndex > 0
                          ? lineBarsData[sportIndex - 1].spots[index].y
                          : 0) -
                      (sportIndex > 0 && index > 0
                          ? lineBarsData[sportIndex - 1].spots[index - 1].y
                          : 0))
              : (thisDateGroupThisSportSum +
                  (sportIndex == 0
                      ? 0
                      : lineBarsData[sportIndex - 1].spots[index].y));

          spots.add(FlSpot(_dateTimeToXValue(dateGroup), y));
          maxY = max(y, maxY);
        }

        final color = sportColorMapping[sport]!;
        final colorUnderCurve = color.withAlpha(128);

        lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) => spot.y != 0,
              getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeColor: color,
              ),
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

    final topY = _getTopY(maxY);
    final minYInterval = switch (displayOption) {
      _DisplayOption.duration => Duration(minutes: 1).inMilliseconds.toDouble(),
      _DisplayOption.distance => 1_000.0,
    };

    final maxXLabelSize = _xLabelMaximumSize(preparedData.keys);
    final maxYLabelSize = _yLabelMaximumSize(
      Iterable.generate(
        (topY / minYInterval).ceil(),
        (i) => (i * minYInterval).toDouble(),
      ),
    );

    final xLabelsReservedHeight = axisTitlesSpace +
        maxXLabelSize.height * magicReservedSizeForLabelsMultiplier;
    final yLabelsReservedWidth = axisTitlesSpace +
        maxYLabelSize.width * magicReservedSizeForLabelsMultiplier;

    final (yAxisTitle, yAxisTitleSize) = _getYAxisTitle(context);
    final yAxisTitleReservedWidth =
        yAxisTitleSize.flipped.width * magicReservedSizeForLabelsMultiplier;

    final maxXLabelsCount = constraints.maxWidth > yLabelsReservedWidth
        ? (constraints.maxWidth -
                yAxisTitleReservedWidth -
                yLabelsReservedWidth) /
            maxXLabelSize.width
        : 0;
    final maxYLabelsCount = constraints.maxHeight > xLabelsReservedHeight
        ? (constraints.maxHeight - xLabelsReservedHeight) ~/
            maxYLabelSize.height
        : 0;

    if (maxXLabelsCount == 0 || maxYLabelsCount == 0) {
      logger.w('Not enough room to display anything');
      return NoneWidget();
    }

    const labelFillAxisProportion = 3 / 4;
    final maxXLabelsInterval =
        preparedData.length / (maxXLabelsCount * labelFillAxisProportion);
    final maxYLabelsInterval =
        topY / (maxYLabelsCount * labelFillAxisProportion);

    final xLabelsInterval = max(1, maxXLabelsInterval.ceil()).toDouble();
    var yLabelsInterval = max(minYInterval, maxYLabelsInterval);
    yLabelsInterval = switch (displayOption) {
      _DisplayOption.duration => Duration(
          minutes: _getNextMultipleOfPreviousPowerOfTen(
            Duration(milliseconds: yLabelsInterval.toInt())
                .inMinutes
                .toDouble(),
          ).toInt(),
        ).inMilliseconds.toDouble(),
      _DisplayOption.distance =>
        _getNextMultipleOfPreviousPowerOfTen(yLabelsInterval)
    };

    final xLabelsShowMin =
        _dateTimeToXValue(preparedData.keys.first).remainder(xLabelsInterval) ==
            0;
    const yLabelShowMin = false;

    final xLabelsShowMax =
        _dateTimeToXValue(preparedData.keys.last).remainder(xLabelsInterval) ==
            0;
    final yLabelsShowMax =
        topY.remainder(yLabelsInterval) == 0 || topY < yLabelsInterval;

    return LineChart(
      LineChartData(
        lineBarsData: lineBarsData,
        betweenBarsData: betweenBarsData,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              minIncluded: xLabelsShowMin,
              maxIncluded: xLabelsShowMax,
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
              minIncluded: yLabelShowMin,
              maxIncluded: yLabelsShowMax,
              interval: yLabelsInterval,
              reservedSize: yLabelsReservedWidth,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                space: axisTitlesSpace,
                child: _yValueToLabel(value).$1,
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

  /// Returns the highest value to display on the Y axis
  double _getTopY(double maxY) => switch (displayOption) {
        _DisplayOption.distance => _getNextMultipleOfPreviousPowerOfTen(maxY),
        _DisplayOption.duration => Duration(
            milliseconds: _getNextMultipleOfPreviousPowerOfTen(maxY).toInt(),
          ).inMilliseconds.toDouble()
      };

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
        final value = spot.y -
            (spot.barIndex == 0
                ? 0
                : touchedSpots
                    .firstWhere(
                      (other) => other.barIndex == spot.barIndex - 1,
                    )
                    .y);
        final distanceText = (value / 1_000).toStringAsFixed(3);
        final durationText = Duration(milliseconds: value.toInt()).toString();
        final text = switch (displayOption) {
          _DisplayOption.distance => distanceText,
          _DisplayOption.duration =>
            durationText.substring(0, durationText.length - '.mmmmmm'.length)
        };
        final sport = sports[spot.barIndex];
        return LineTooltipItem(
          spot.barIndex != touchedSpots.length - 1
              ? ''
              : '${switch (groupBy) {
                  _GroupBy.day => DateFormat.yMMMd,
                  _GroupBy.month => DateFormat.yMMM,
                  _GroupBy.year => DateFormat.y,
                }(Platform.localeName).format(
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
                  '$text',
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
    final text = switch (displayOption) {
      _DisplayOption.distance =>
        '${LocaleKeys.activity.statistics.distance().translate(context)}'
            ' (${LocaleKeys.units.kilometersShort().translate(context)})',
      _DisplayOption.duration =>
        LocaleKeys.activity.statistics.duration().translate(context)
    };
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
        (maxY / previousPowerOf10).ceil() * previousPowerOf10;
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

  /// Groups given activities by either year/month/day, then by sport.
  ///
  /// Also ensures that there is no missing entry between two dates. For
  /// instance if grouping by month and the keys `DateTime(1999, 1)` and
  /// `DateTime(1999, 4)` are present, then so do `DateTime(1999, 2)` and
  /// `DateTime(1999, 3)`.
  ///
  /// Also returns the set of all encountered sports.
  (SplayTreeMap<DateTime, Map<Sport, double>>, Set<Sport>) _prepareActivityData(
    List<Activity> activities,
  ) {
    final sumsByDateGroup = SplayTreeMap<DateTime, Map<Sport, double>>();
    // What sports are concerned by this activity set.
    final presentSports = <Sport>{};

    for (final activity in activities) {
      final dateGroup = DateTime(
        activity.startTime.year,
        groupBy != _GroupBy.year ? activity.startTime.month : 1,
        groupBy == _GroupBy.day ? activity.startTime.day : 1,
      );
      final sport = activity.sport ?? Sport.other;

      presentSports.add(sport);

      if (sumsByDateGroup.isEmpty) {
        sumsByDateGroup[dateGroup] = {};
      } else if (!sumsByDateGroup.containsKey(dateGroup)) {
        // Ensure all keys are present, there is no missing day/month/year.
        if (dateGroup.isBefore(sumsByDateGroup.firstKey()!)) {
          while (!sumsByDateGroup.containsKey(dateGroup)) {
            final nextKey = switch (groupBy) {
              _GroupBy.day =>
                DateUtils.addDaysToDate(sumsByDateGroup.firstKey()!, -1),
              _GroupBy.month => DateUtils.addMonthsToMonthDate(
                  sumsByDateGroup.firstKey()!,
                  -1,
                ),
              _GroupBy.year => DateTime(sumsByDateGroup.firstKey()!.year - 1),
            };
            sumsByDateGroup[nextKey] = {};
          }
        } else {
          while (!sumsByDateGroup.containsKey(dateGroup)) {
            final nextKey = switch (groupBy) {
              _GroupBy.day =>
                DateUtils.addDaysToDate(sumsByDateGroup.lastKey()!, 1),
              _GroupBy.month => DateUtils.addMonthsToMonthDate(
                  sumsByDateGroup.lastKey()!,
                  1,
                ),
              _GroupBy.year => DateTime(sumsByDateGroup.lastKey()!.year + 1),
            };
            sumsByDateGroup[nextKey] = {};
          }
        }
      }

      sumsByDateGroup[dateGroup]![sport] =
          (sumsByDateGroup[dateGroup]![sport] ?? 0) +
              switch (displayOption) {
                _DisplayOption.distance => (activity.distanceInMeters ?? 0.0),
                _DisplayOption.duration =>
                  activity.duration.inMilliseconds.toDouble()
              };
    }

    // Add empty data just before that in order to be able to display anything
    if (sumsByDateGroup.length == 1) {
      final previous = switch (groupBy) {
        _GroupBy.day =>
          DateUtils.addDaysToDate(sumsByDateGroup.firstKey()!, -1),
        _GroupBy.month => DateUtils.addMonthsToMonthDate(
            sumsByDateGroup.firstKey()!,
            -1,
          ),
        _GroupBy.year => DateTime(sumsByDateGroup.firstKey()!.year - 1),
      };
      sumsByDateGroup[previous] = {};
    }

    return (sumsByDateGroup, presentSports);
  }

  static const _millisecondsPerDay = 1_000 * 60 * 60 * 24;

  double _dateTimeToXValue(DateTime dateTime) => switch (groupBy) {
        _GroupBy.day => dateTime.millisecondsSinceEpoch / _millisecondsPerDay,
        _GroupBy.month =>
          (dateTime.year * DateTime.monthsPerYear + dateTime.month - 1)
              .toDouble(),
        _GroupBy.year => dateTime.year.toDouble()
      };

  DateTime _xValueToDateTime(double x) => switch (groupBy) {
        _GroupBy.day =>
          DateTime.fromMillisecondsSinceEpoch(x.toInt() * _millisecondsPerDay),
        _GroupBy.month => DateTime(
            (x / DateTime.monthsPerYear).toInt(),
            x.remainder(DateTime.monthsPerYear).toInt() + 1,
          ),
        _GroupBy.year => DateTime(x.toInt()),
      };

  /// Convert a chart x value (representing a DateTime in milliseconds since
  /// Epoch) in its Widget label, with the size it will take.
  (Widget, Size) _xValueToLabel(double x) {
    final text = switch (groupBy) {
      _GroupBy.day => DateFormat.yMMMd(Platform.localeName),
      _GroupBy.month => DateFormat.yMMM(Platform.localeName),
      _GroupBy.year => DateFormat.y(Platform.localeName),
    }
        .format(_xValueToDateTime(x));
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
    final asDistanceInMeters = y;
    final asDurationText = Duration(milliseconds: y.toInt()).toString();
    final text = switch (displayOption) {
      _DisplayOption.duration =>
        asDurationText.substring(0, asDurationText.length - '.mmmmmm'.length),
      _DisplayOption.distance => (asDistanceInMeters / 1_000).toInt().toString()
    };
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
